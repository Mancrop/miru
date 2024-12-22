import 'dart:io';
import 'package:miru_app/models/download_job.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/path_utils.dart';
import 'package:path/path.dart' as p;
import 'package:miru_app/data/services/download/download_manager.dart';

final DownloadManager downloadManager = DownloadManager();

class OfflineResourceService {
  static String newDirectory(String name, ResourceType type) {
    // 创建文件夹
    String sanitizedName = sanitizeFileName(name);
    String rootPath = MiruStorage.getSetting(SettingKey.downloadPath);
    String path =
        p.join(rootPath, type.toString().split('.').last, sanitizedName);
    Directory(path).createSync(recursive: true);
    return path;
  }

  static void startMangaDownloadJob(String package, String url,
      ExtensionDetail details, int ep, List<int> chaptersToDownload) async {
    // 下载漫画
    OfflineResource resource = OfflineResource();
    resource.source = ResourceSource.fromExtension;
    resource.type = ResourceType.manga;
    resource.package = package;
    resource.url = url;
    resource.title = details.title;
    resource.cover = details.cover;
    resource.path =
        newDirectory('$package ${details.title}', ResourceType.manga);
    final episodes = details.episodes ?? [];
    final curEp = episodes[ep];
    final epInstance = Ep()
      ..title = curEp.title
      ..items = []
      ..subPath = sanitizeFileName(curEp.title);
    epInstance.items = chaptersToDownload.map((index) {
      final episode = episodes[ep].urls[index];
      final item = Item();
      item.title = episode.name;
      item.subPath = sanitizeFileName(episode.name);
      item.url = episode.url;
      return item;
    }).toList();
    resource.eps = [epInstance];
    // logger.info('Send Manga Download Job: $resource');
    // for (var item in resource.items) {
    //   logger.info('Send Manga Download Job: ${item.title} ${item.url}');
    // }
    // logger.info("package: $package");
    // final runtime = ExtensionUtils.runtimes[package]!;
    // for (var item in resource.eps[0].items) {
    //   final watchData = await runtime.watch(item.url) as ExtensionMangaWatch;
    //   final path = p.join(resource.path, item.subPath);
    //   Directory(path).createSync(recursive: true);
    //   for (var (idx, pageUrl) in watchData.urls.indexed) {
    //     logger.info('servie pageUrl: $pageUrl, headers: ${watchData.headers}');
    //     final res = await Dio().get(pageUrl,
    //         options: Options(
    //             responseType: ResponseType.bytes, headers: watchData.headers));
    //     final picType = getImageType(res.data).extension;
    //     final picPath = p.join(path, '$idx$picType');
    //     File(picPath).writeAsBytes(res.data);
    //   }
    // }
    // logger.info('Send Manga Download Job: $resource');
    downloadManager.addDownload(resource);
  }
}
