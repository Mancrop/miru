import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/offline_resource.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/image_type.dart';
import 'package:miru_app/utils/log.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:path/path.dart' as p;

final DownloadManager downloadManager = DownloadManager();

class OfflineResourceService {
  static String sanitizeFileName(String fileName) {
    // 移除或替换不允许的字符
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '') // Windows非法字符
        .replaceAll(RegExp(r'[\x00-\x1F]'), '') // 控制字符
        .replaceAll(RegExp(r'\s+'), ' ') // 多个空格替换为单个
        .trim(); // 移除首尾空格
  }

  static String newDirectory(String name, ResourceType type) {
    // 创建文件夹
    String sanitizedName = sanitizeFileName(name);
    String rootPath = MiruStorage.getSetting(SettingKey.downloadPath);
    String path =
        p.join(rootPath, type.toString().split('.').last, sanitizedName);
    Directory(path).createSync(recursive: true);
    return path;
  }

  static List<Ep> createVirtualEps(List<ExtensionEpisodeGroup> episodes) {
    return episodes
        .map((episode) => Ep()
          ..virtualResource = true
          ..title = episode.title
          ..items = [])
        .toList();
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
    resource.path = newDirectory(details.title, ResourceType.manga);
    final episodes = details.episodes ?? [];
    resource.eps = createVirtualEps(episodes);
    resource.eps[ep].items = chaptersToDownload.map((index) {
      final episode = episodes[ep].urls[index];
      final item = Item();
      item.title = episode.name;
      item.subPath = episode.name;
      item.url = episode.url;
      return item;
    }).toList();
    // logger.info('Send Manga Download Job: $resource');
    // for (var item in resource.items) {
    //   logger.info('Send Manga Download Job: ${item.title} ${item.url}');
    // }
    logger.info("package: $package");
    final runtime = ExtensionUtils.runtimes[package]!;
    for (var item in resource.eps[ep].items) {
      final watchData = await runtime.watch(item.url) as ExtensionMangaWatch;
      final path = p.join(resource.path, item.subPath);
      Directory(path).createSync(recursive: true);
      for (var (idx, pageUrl) in watchData.urls.indexed) {
        final res = await Dio().get(pageUrl,
            options: Options(
                responseType: ResponseType.bytes, headers: watchData.headers));
        final picType = getImageType(res.data).extension;
        final picPath = p.join(path, '$idx$picType');
        File(picPath).writeAsBytes(res.data);
      }
    }
  }
}
