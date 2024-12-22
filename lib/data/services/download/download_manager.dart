// This is implementation is inspired by flutter_download_manager
// See https://github.com/nabil6391/flutter_download_manager
import 'dart:collection';
import 'package:miru_app/data/services/download/download_interface.dart';
import 'package:miru_app/data/services/download/manga_downloader.dart';
import 'package:miru_app/models/download_job.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/data/services/database_service.dart';

class IdPool {
  final Set<int> _usedIds = {};
  int _nextId = 1;

  // 获取一个新的 ID
  int getNewId() {
    while (_usedIds.contains(_nextId)) {
      _nextId++;
    }
    _usedIds.add(_nextId);
    return _nextId;
  }

  // 释放一个已使用的 ID
  void releaseId(int id) {
    _usedIds.remove(id);
    if (_usedIds.isEmpty) {
      _nextId = 1;
    }
  }

  void getSpecNewIdStrict(int id) {
    if (_usedIds.contains(id)) {
      assert(false, 'ID $id is already used');
    } else {
      _usedIds.add(id);
      if (id >= _nextId) {
        _nextId = id + 1;
      }
    }
  }
}

// Task类，用于提供一个封装过的DownloadInterface
// 用于外部类获取下载任务的信息
// 避免对下载任务的直接操作
// 由于无法避免的原因
// 它需要与UI层耦合
class TaskInternal {
  late DownloadInterface _download;
  bool isExpanded = false;

  TaskInternal({required DownloadInterface download}) {
    _download = download;
  }

  double get progress => _download.progress;

  DownloadStatus get status => _download.status;

  String get name => _download.name;

  String get url => _download.url;

  String? get detail => _download.detail;

  void pause() {
    _download.pause();
    // 更新数据库
    assert(_download.downloadJob.id == _download.id);
    DatabaseService.putDownloadJobsById(_download.id, _download.downloadJob);
  }

  void resume() {
    _download.resume();
    // 更新数据库
    assert(_download.downloadJob.id == _download.id);
    DatabaseService.putDownloadJobsById(_download.id, _download.downloadJob);
  }

  void cancel() {
    _download.cancel();
    // 更新数据库
    assert(_download.downloadJob.id == _download.id);
    DatabaseService.putDownloadJobsById(_download.id, _download.downloadJob);
  }
}

class DownloadManager {
  final _queue = Queue<DownloadInterface>();
  final _downloading = List<DownloadInterface>.empty(growable: true);
  final _others = List<DownloadInterface>.empty(growable: true);
  final _idPool = IdPool();

  bool get isDownloading => _downloading.isNotEmpty && _queue.isNotEmpty;

  static late DownloadManager _instance;

  factory DownloadManager() {
    return _instance;
  }

  static void init() {
    _instance = DownloadManager._internal();
  }

  DownloadManager._internal() {
    _execution();
  }

  double get progress {
    if (!isDownloading) {
      return 0.0;
    }
    final total = _downloading.length;
    var count = 0;
    for (final download in _downloading) {
      count += download.progress.toInt();
    }
    return count / total;
  }

  void addDownload(OfflineResource resource) async {
    final downloadType = resource.type;
    final id = _idPool.getNewId();

    // 确保Job的id与Downloader的id一致
    final downloadJob = DownloadJob(jobId: id, resource: resource);
    await DatabaseService.putDownloadJobsById(id, downloadJob);
    switch (downloadType) {
      case ResourceType.manga:
        _queue.add(MangaDownloader(downloadJob, id));
        break;
      case ResourceType.video:
        assert(false, 'Not implemented');
        break;
      case ResourceType.novel:
        assert(false, 'Not implemented');
        break;
    }
  }

  void _execution() async {
    while (true) {
      final maxTasks = MiruStorage.getSetting(SettingKey.downloadMaxTasks);

      // clear not active download
      _downloading.removeWhere((download) {
        if (download.status.isComplete ||
            download.status.isCanceled ||
            download.status.isFailed) {
          if (download.status.isComplete) {
            download.releaseResource();
          }
          _others.add(download);
          return true;
        } else if (download.status.isPaused) {
          _queue.add(download);
          return true;
        }
        return false;
      });
      _queue.removeWhere((download) {
        if (download.status.isComplete ||
            download.status.isCanceled ||
            download.status.isFailed) {
          if (download.status.isComplete) {
            download.releaseResource();
          }
          _others.add(download);
          return true;
        }
        return false;
      });
      while (_downloading.length < maxTasks) {
        if (_queue.isEmpty) {
          break;
        }
        // 需要找到第一个是queued的任务,而不是paused的任务
        final download = _queue.firstWhere(
            (download) => download.status.isQueued,
            orElse: () => _queue.first);
        if (download.status.isPaused) {
          break;
        }
        download.download();
        _downloading.add(download);
        _queue.remove(download);
      }
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }

  void pauseAll() {
    for (final download in _downloading) {
      download.pause();
      // 更新数据库
      assert(download.downloadJob.id == download.id);
      DatabaseService.putDownloadJobsById(download.id, download.downloadJob);
    }
  }

  void resumeAll() {
    final maxTasks = MiruStorage.getSetting(SettingKey.downloadMaxTasks);
    for (final download in _queue) {
      if (download.status.isPaused) {
        if (_downloading.length < maxTasks) {
          download.resume();
          _downloading.add(download);
          // 更新数据库
          assert(download.downloadJob.id == download.id);
          DatabaseService.putDownloadJobsById(
              download.id, download.downloadJob);
        } else {
          break;
        }
      }
    }
  }

  void cancelAll() {
    for (final download in _downloading) {
      download.cancel();
      // 更新数据库
      assert(download.downloadJob.id == download.id);
      DatabaseService.putDownloadJobsById(download.id, download.downloadJob);
    }
    for (final download in _queue) {
      download.cancel();
      // 更新数据库
      assert(download.downloadJob.id == download.id);
      DatabaseService.putDownloadJobsById(download.id, download.downloadJob);
    }
  }

  // 因为更新有延迟,所以返回的时候需要过滤掉当前状态与状态队列不一致的元素
  List<TaskInternal> get queue => _queue
      .where((download) => download.status.isQueued || download.status.isPaused)
      .map((download) => TaskInternal(download: download))
      .toList();

  List<TaskInternal> get downloading => _downloading
      .where((download) => download.status.isDownloading)
      .map((download) => TaskInternal(download: download))
      .toList();

  List<TaskInternal> get others => _others
      .where((download) =>
          download.status.isComplete ||
          download.status.isCanceled ||
          download.status.isFailed)
      .map((download) => TaskInternal(download: download))
      .toList();

  void pauseById(int id) {
    final download = _downloading.firstWhere((download) => download.id == id);
    download.pause();
    // 更新数据库
    assert(download.downloadJob.id == download.id);
    DatabaseService.putDownloadJobsById(download.id, download.downloadJob);
  }

  void resumeById(int id) {
    final download = _downloading.firstWhere((download) => download.id == id);
    download.resume();
    // 更新数据库
    assert(download.downloadJob.id == download.id);
    DatabaseService.putDownloadJobsById(download.id, download.downloadJob);
  }

  void cancelById(int id) {
    final download = _downloading.firstWhere((download) => download.id == id);
    download.cancel();
    // 更新数据库
    assert(download.downloadJob.id == download.id);
    DatabaseService.putDownloadJobsById(download.id, download.downloadJob);
  }

  void pauseByIds(List<int> ids) {
    for (final id in ids) {
      pauseById(id);
    }
  }

  void resumeByIds(List<int> ids) {
    for (final id in ids) {
      resumeById(id);
    }
  }

  void cancelByIds(List<int> ids) {
    for (final id in ids) {
      cancelById(id);
    }
  }

  void pauseByIndex(int index) {
    final download = _downloading[index];
    download.pause();
    // 更新数据库
    assert(download.downloadJob.id == download.id);
    DatabaseService.putDownloadJobsById(download.id, download.downloadJob);
  }
}
