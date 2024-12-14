import 'dart:io';

import 'package:dio/dio.dart';
import 'package:miru_app/data/services/download/download_interface.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/models/download_job.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/offline_resource.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/image_type.dart';
import 'package:miru_app/utils/request.dart';
import 'package:path/path.dart' as p;

class MangaDownloader extends DownloadInterface {
  final gDio = dio;
  var _progress = 0.0;
  var _status = DownloadStatus.queued;
  late String _name;
  late String _url;
  late DownloadJob _job;

  MangaDownloader(DownloadJob job) {
    _job = job;
    _name = job.resource.value!.title;
    _url = job.resource.value!.url!;
  }

  @override
  DownloadStatus get status => _status;

  @override
  double get progress => _progress;

  @override
  DownloaderType getDownloaderType() {
    return DownloaderType.mangaDownloader;
  }

  Future<void> pauseInternal() async {
    while (status == DownloadStatus.paused || status == DownloadStatus.queued) {
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<DownloadStatus> downloadInternal(
      int total, ExtensionService runtime, OfflineResource resource) async {
    var count = 0;
    for (var eps in resource.eps) {
      for (var item in eps.items) {
        if (_status == DownloadStatus.canceled) {
          return DownloadStatus.canceled;
        }
        pauseInternal();
        _progress = count / total;
        final path = p.join(resource.path, eps.subPath, item.subPath);
        if (Directory(path).existsSync()) {
          count++;
          continue;
        }
        final watchData = await runtime.watch(item.url) as ExtensionMangaWatch;
        Directory(path).createSync(recursive: true);
        for (var (idx, pageUrl) in watchData.urls.indexed) {
          if (_status == DownloadStatus.canceled) {
            return DownloadStatus.canceled;
          }
          pauseInternal();
          final res = await gDio.get(pageUrl,
              options: Options(
                  responseType: ResponseType.bytes,
                  headers: watchData.headers));
          final picType = getImageType(res.data).extension;
          final picPath = p.join(path, '$idx$picType');
          File(picPath).writeAsBytes(res.data);
        }
        count++;
      }
    }
    _progress = 1.0;
    return DownloadStatus.completed;
  }

  @override
  Future<DownloadStatus> download() async {
    try {
      await _job.resource.load();
      var resource = _job.resource.value!;

      var total = 0;
      for (var ep in resource.eps) {
        total += ep.items.length;
      }
      if (total == 0) {
        _status = DownloadStatus.failed;
        return DownloadStatus.failed;
      }
      _status = DownloadStatus.downloading;
      final runtime = ExtensionUtils.runtimes[resource.package]!;
      // 如果在下载的过程中，新的同章节请求过来了，怎么办呢？
      // 此时需要下载管理器重新发送一个新的请求
      // 为了避免重复下载，需要在下载中判断是否某个分集已经下载过
      _status = await downloadInternal(total, runtime, resource);
    } catch (e) {
      _status = DownloadStatus.failed;
    }
    return _status;
  }

  @override
  Future<void> pause() async {
    _status = DownloadStatus.paused;
  }

  @override
  Future<void> resume() async {
    _status = DownloadStatus.downloading;
  }

  @override
  Future<void> cancel() async {
    _status = DownloadStatus.canceled;
  }

  @override
  String get name => _name;

  @override
  String get url => _url;
}
