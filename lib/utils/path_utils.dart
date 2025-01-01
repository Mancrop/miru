import 'dart:io';
import 'package:miru_app/utils/android_permission.dart';
import 'package:miru_app/utils/log.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:path/path.dart' as path;

String sanitizeFileName(String fileName) {
  // 移除或替换不允许的字符
  return fileName
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), '') // Windows非法字符
      .replaceAll(RegExp(r'[\x00-\x1F]'), '') // 控制字符
      .replaceAll(RegExp(r'\s+'), ' ') // 多个空格替换为单个
      .trim(); // 移除首尾空格
}

/// 获取文件夹中所有文件的路径，并按文件名中的《数字部分》排序
/// 注意这是数字部分，而不是文件名中的数字字符
/// [directoryPath] 文件夹路径
/// [ascending] 是否按升序排序（默认为 true，升序；false 为降序）
Future<List<String>> getSortedFiles(String directoryPath,
    {bool ascending = true}) async {
  /// 从文件名中提取数字部分
  int extractNumber(String fileName) {
    // 使用正则表达式匹配文件名开头的数字部分
    RegExp regExp = RegExp(r'^(\d+)');
    Match? match = regExp.firstMatch(fileName);

    if (match != null) {
      // 提取匹配的数字部分并转换为整数
      return int.parse(match.group(1)!);
    }

    // 如果文件名中没有数字部分，返回 0（或其他默认值）
    return 0;
  }

  // 获取文件夹
  Directory directory = Directory(directoryPath);

  // 检查文件夹是否存在
  if (!await directory.exists()) {
    throw Exception('文件夹不存在: $directoryPath');
  }

  // 列出文件夹中的所有内容
  List<FileSystemEntity> entities = directory.listSync();

  // 过滤出文件（排除文件夹）
  List<File> files = entities.whereType<File>().toList();

  // 按文件名中的数字部分排序
  files.sort((a, b) {
    // 提取文件名中的数字部分
    int numA = extractNumber(a.uri.pathSegments.last);
    int numB = extractNumber(b.uri.pathSegments.last);

    // 根据 ascending 参数决定排序顺序
    return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
  });

  // 返回文件的路径列表
  return files.map((file) => file.path).toList();
}

String getMediaFolderPath() {
  late String dirPath;

  if (Platform.isAndroid) {
    // 在安卓中采用DCIM进行储存
    dirPath = path.join('/storage/emulated/0/Documents', 'Miru');
  } else {
    dirPath = path.join(MiruDirectory.getDirectory, 'download');
  }

  return dirPath;
}

// 需要在ui界面显示后调用，因此有些地方应使用原始的createSync方法
Future<bool> miruCreateFolder(String folder, {bool recursive = true}) async {
  try {
    // 主要是为了避免在安卓中创建文件夹没有权限的问题
    if (Platform.isAndroid) {
      // 检测folder是否是外部存储的子文件夹，而且不是DCIM的子文件夹
      if (folder.startsWith('/storage/emulated/0')) {
        await requestFullStoragePermissions();
        if (Directory(folder).existsSync()) {
          return true;
        }
        Directory(folder).createSync(recursive: recursive);
        return true;
      }
      // 检测是否是内部存储的子文件夹
      if (folder.startsWith(MiruDirectory.getDirectory)) {
        if (Directory(folder).existsSync()) {
          return true;
        }
        Directory(folder).createSync(recursive: recursive);
        return true;
      }
      throw Exception('Can not create folder: $folder');
    } else {
      Directory(folder).createSync(recursive: recursive);
      return true;
    }
  } catch (e) {
    logger.warning('miruCreateFolder error: $e');
    return false;
  }
}

// 需要在ui界面显示后调用，因此有些地方应使用原始的createSync方法
Future<bool> miruCreatePath(String path, {bool recursive = true}) async {
  try {
    // 主要是为了避免在安卓中创建文件没有权限的问题
    final file = File(path);
    if (Platform.isAndroid) {
      // 检测path是否是外部存储的子文件夹，而且不是DCIM的子文件夹
      if (path.startsWith('/storage/emulated/0')) {
        await requestFullStoragePermissions();
        if (file.existsSync()) {
          return true;
        }
        file.createSync(recursive: recursive);
        return true;
      }
      // 检测是否是内部存储的子文件夹
      if (path.startsWith(MiruDirectory.getDirectory)) {
        if (file.existsSync()) {
          return true;
        }
        file.createSync(recursive: recursive);
        return true;
      }
      throw Exception('Can not create file: $path');
    } else {
      if (file.existsSync()) {
        return true;
      }
      file.createSync(recursive: recursive);
      return true;
    }
  } catch (e) {
    logger.warning('miruCreatePath error: $e');
    return false;
  }
}
