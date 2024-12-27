import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/services/download/download_interface.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/models/download_job.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/image_type.dart';
import 'package:path/path.dart' as p;

class MangaDownloader extends DownloadInterface {
  late int _id;
  var _progress = 0.0;
  var _status = DownloadStatus.queued;
  late String _name;
  late String _url;
  late DownloadJob _job;

  MangaDownloader(DownloadJob job, int id) {
    _job = job;
    _name = job.resource!.title;
    _url = job.resource!.url!;
    _id = id;
  }

  bool deadStatus() {
    return _status == DownloadStatus.canceled ||
        _status == DownloadStatus.failed ||
        _status == DownloadStatus.completed;
  }

  @override
  int get id => _id;

  @override
  String? get detail => _job.resource?.package;

  @override
  DownloadStatus get status => _status;

  @override
  double get progress => _progress;

  @override
  DownloaderType getDownloaderType() {
    return DownloaderType.mangaDownloader;
  }

  // Future<void> pauseInternal() async {
  //   while (status == DownloadStatus.paused || status == DownloadStatus.queued) {
  //     await Future.delayed(Duration(seconds: 1));
  //   }
  // }

  Future<DownloadStatus> downloadInternal(
      int total, ExtensionService runtime, OfflineResource resource) async {
    var count = 0;
    for (var eps in resource.eps) {
      for (var item in eps.items) {
        if (_status == DownloadStatus.canceled) {
          return DownloadStatus.canceled;
        }
        while (status == DownloadStatus.paused ||
            status == DownloadStatus.queued) {
          await Future.delayed(Duration(seconds: 1));
        }
        _progress = count / total;
        final path = p.join(resource.path, eps.subPath, item.subPath);
        final watchData = await runtime.watch(item.url) as ExtensionMangaWatch;
        Directory(path).createSync(recursive: true);

        // 获取目录中的所有文件
        final existingFiles =
            Directory(path).listSync().whereType<File>().toList();

        for (var (idx, pageUrl) in watchData.urls.indexed) {
          if (_status == DownloadStatus.canceled) {
            return DownloadStatus.canceled;
          }
          while (status == DownloadStatus.paused ||
              status == DownloadStatus.queued) {
            await Future.delayed(Duration(seconds: 1));
          }
          final File? existingFile = existingFiles.firstWhereOrNull(
            (file) => p.basenameWithoutExtension(file.path) == '$idx',
          );

          if (existingFile != null) {
            continue;
          }
          final res = await Dio().get(pageUrl,
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
    while (status == DownloadStatus.paused || status == DownloadStatus.queued) {
      await Future.delayed(Duration(seconds: 1));
    }
    _progress = 1.0;
    return DownloadStatus.completed;
  }

  @override
  Future<DownloadStatus> download() async {
    try {
      var resource = _job.resource!;

      var total = 0;
      for (var ep in resource.eps) {
        total += ep.items.length;
      }
      if (total == 0) {
        _status = DownloadStatus.failed;
        return DownloadStatus.failed;
      }
      _status = DownloadStatus.downloading;
      // logger.info('Start download $total items');
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
    if (deadStatus()) {
      return;
    }
    _status = DownloadStatus.paused;
  }

  @override
  Future<void> resume() async {
    if (deadStatus()) {
      return;
    }
    _status = DownloadStatus.downloading;
  }

  @override
  Future<void> cancel() async {
    if (deadStatus()) {
      return;
    }
    _status = DownloadStatus.canceled;
  }

  @override
  DownloadJob get downloadJob => _job;

  @override
  void releaseResource() {
    _job.setResourceToNull();
  }

  @override
  String get name => _name;

  @override
  String get url => _url;

  @override
  bool get isPaused => _status == DownloadStatus.paused;

  @override
  bool get isDownloading => _status == DownloadStatus.downloading;

  @override
  bool get isQueued => _status == DownloadStatus.queued;

  @override
  bool get isComplete => _status == DownloadStatus.completed;

  @override
  bool get isCanceled => _status == DownloadStatus.canceled;

  @override
  bool get isFailed => _status == DownloadStatus.failed;
}
