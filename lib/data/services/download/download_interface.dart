import 'package:miru_app/models/download_job.dart';

enum DownloaderType {
  mangaDownloader,
  vedioDownloader,
}

abstract class DownloadInterface {

  double get progress;

  DownloaderType getDownloaderType();

  DownloadStatus get status;

  String get name;

  String get url;

  Future<DownloadStatus> download();

  Future<void> pause();

  Future<void> resume();

  Future<void> cancel();
}
