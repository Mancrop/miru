import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/data/services/download/download_interface.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/models/download_job.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/log.dart';
import 'package:miru_app/utils/path_utils.dart';

class VideoDownloader extends DownloadInterface {
  late int _id;
  var _progress = 0.0;
  var _status = DownloadStatus.queued;
  late String _name;
  late String _url;
  late DownloadJob _job;
  late MiruDetail? _detail;
  late String? detailPackage;
  late String? detailUrl;

  VideoDownloader(DownloadJob job, int id) {
    _job = job;
    _name = job.resource!.title;
    _url = job.resource!.url!;
    _id = id;
    detailPackage = job.resource?.package;
    detailUrl = job.resource?.url;
    if (detailPackage != null && detailUrl != null) {
      DatabaseService.getMiruDetail(detailPackage!, detailUrl!).then((value) {
        _detail = value;
      });
    } else {
      logger.warning('Video downloader: Resource package or url is null');
    }
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
    return DownloaderType.vedioDownloader;
  }

  Future<(String url, List<Segment> segments)> _getM3U8Segments(String url, Map<String, String> headers) async {
    logger.info('get_m3u8_segments_url: $url, headers: $headers');
    final response = await Dio().get(
      url,
      options: Options(
        headers: headers,
        responseType: ResponseType.stream,
      ),
    );

    // 检查content-type是否为m3u8
    final contentType = response.headers.value('content-type')?.toLowerCase();
    if (contentType == null ||
        !contentType.contains('mpegurl') &&
            !contentType.contains('m3u8') &&
            !contentType.contains('mp2t')) {
      throw Exception('Invalid content type: $contentType');
    }

    // 接收数据到变量
    final stream = response.data.stream;
    final buffer = StringBuffer();

    await for (final data in stream) {
      buffer.write(utf8.decode(data));
    }
    final m3u8Content = buffer.toString();
    if (m3u8Content.isEmpty) {
      throw Exception('Empty m3u8 content');
    }

    late HlsPlaylist playlist;
    try {
      playlist = await HlsPlaylistParser.create().parseString(
        response.realUri,
        m3u8Content,
      );
    } on ParserException catch (e) {
      logger.severe(e);
      throw Exception('Failed to parse m3u8: $e');
    }

    if (playlist is HlsMasterPlaylist) {
      // Master playlist contains multiple quality variants
      // Get the first variant (usually highest quality)
      final variant = playlist.variants.first;
      final variantUrl = variant.url.toString();
      
      // Recursively get segments from the variant playlist
      return await _getM3U8Segments(variantUrl, headers);
    } else if (playlist is HlsMediaPlaylist) {
      // Media playlist contains the actual segments
      return (url, playlist.segments);
    } else {
      throw Exception('Unknown playlist type');
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
        while (status == DownloadStatus.paused ||
            status == DownloadStatus.queued) {
          await Future.delayed(Duration(seconds: 1));
        }
        _progress = count / total;
        
        final watchData = await runtime.watch(item.url) as ExtensionBangumiWatch;
          final curPath = await miruCreateFolderInTree(
              resource.path, [eps.subPath, item.subPath]);
          if (curPath == null) {
            logger.warning('Failed to create directory: ${[eps.subPath, item.subPath]}');
            return DownloadStatus.failed;
          }

        try {
          final (playlistUrl, segments) = await _getM3U8Segments(watchData.url, watchData.headers ?? {});
          final segmentCount = segments.length;
          var downloadedCount = 0;

          for (var segment in segments) {
            if (_status == DownloadStatus.canceled) {
              return DownloadStatus.canceled;
            }
            while (status == DownloadStatus.paused ||
                status == DownloadStatus.queued) {
              await Future.delayed(Duration(seconds: 1));
            }

            // 构建完整的分片URL
            final segmentUri = segment.url;
            if (segmentUri == null) {
              logger.warning('Segment URL is null');
              continue;
            }
            
            logger.info('Raw segment URL: $segmentUri');
            
            String segmentUrl;
            try {
              final parsedSegmentUri = Uri.parse(segmentUri);
              segmentUrl = parsedSegmentUri.hasScheme ? 
                  segmentUri : 
                  Uri.parse(playlistUrl).resolve(segmentUri).toString();
              
              logger.info('Final segment URL: $segmentUrl');
            } catch (e) {
              logger.warning('Failed to parse segment URL: $segmentUri', e);
              continue;
            }
            final segmentIndex = segments.indexOf(segment);
            final fileName = '$segmentIndex.ts';

            try {
              final response = await Dio().get(
                segmentUrl,
                options: Options(
                  responseType: ResponseType.bytes,
                  headers: watchData.headers
                ),
              );

              await miruWriteFileBytes(curPath, fileName, response.data);
              downloadedCount++;
              _progress = (count + downloadedCount / segmentCount) / total;
            } catch (e) {
              logger.warning('Failed to download segment: $segmentUrl', e);
              continue;
            }
          }
        } catch (e) {
          logger.warning('Failed to process playlist: ${watchData.url}', e);
          return DownloadStatus.failed;
        }

        final epTitle = eps.title;
        final itemTitle = item.title;
        final offlineResource = _detail?.offlineResource ?? {};
        offlineResource[epTitle] ??= {};
        offlineResource[epTitle]![itemTitle] = curPath;
        if (_detail != null) {
          _detail!.offlineResource = offlineResource;
          await DatabaseService.updateMiruDetail(
              detailPackage!, detailUrl!, _detail!);
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
      _job.status = _status;

      final runtime = ExtensionUtils.runtimes[resource.package]!;
      _status = await downloadInternal(total, runtime, resource);
      _job.status = _status;
    } catch (e) {
      _status = DownloadStatus.failed;
      _job.status = _status;
      logger.warning('Download failed', e);
    }
    return _status;
  }

  @override
  Future<void> pause() async {
    if (deadStatus()) {
      return;
    }
    _status = DownloadStatus.paused;
    _job.status = _status;
  }

  @override
  Future<void> resume() async {
    if (deadStatus()) {
      return;
    }
    _status = DownloadStatus.downloading;
    _job.status = _status;
  }

  @override
  Future<void> cancel() async {
    if (deadStatus()) {
      return;
    }
    _status = DownloadStatus.canceled;
    _job.status = _status;
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
