// This is implementation is inspired by flutter_download_manager
// See https://github.com/nabil6391/flutter_download_manager

import 'dart:collection';
import 'package:miru_app/models/download_job.dart';

class DownloadManager {
  final _queue = Queue<DownloadJob>();
  final _ongoing = <int, DownloadJob>{};

  static late final DownloadManager _instance;

  static void initialize() {
    _instance = DownloadManager._internal();
  }

  DownloadManager._internal();

  factory DownloadManager() {
    return _instance;
  }
}
