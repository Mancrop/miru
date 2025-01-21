import 'dart:io';
import 'dart:typed_data';
import 'package:miru_app/utils/log.dart';
import 'package:path/path.dart' as p;
import 'package:saf_stream/saf_stream.dart';
import 'package:uri_to_file/uri_to_file.dart';

final _saf = SafStream();

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

// 需要在ui界面显示后调用
Future<bool> miruCreateFolder(String folder, {bool recursive = true}) async {
  try {
    if (Directory(folder).existsSync()) {
      return true;
    }
    Directory(folder).createSync(recursive: recursive);
    return true;
  } catch (e) {
    logger.warning('miruCreateFolder error: $e');
    return false;
  }
}

// 需要在ui界面显示后调用
Future<bool> miruCreateFile(String path, {bool recursive = true}) async {
  try {
    if (!Platform.isAndroid) {
      if (File(path).existsSync()) {
        return true;
      }
      File(path).createSync(recursive: recursive);
    } else {
      // 使用SAF对安卓文件进行读写
      // 在安卓中使用uri
    }
    return true;
  } catch (e) {
    logger.warning('miruCreateFile error: $e');
    return false;
  }
}

Future<Uint8List> miruReadFileBytes(String path) async {
  // 用于读取外部文件（特指安卓/苹果）
  // 返回字节流
  if (!Platform.isAndroid) {
    return File(path).readAsBytesSync();
  } else {
    return _saf.readFileBytes(path);
  }
}

Future<File> miruGetFile(String path) async {
  if (!Platform.isAndroid) {
    return File(path);
  } else {
    return await toFile(path);
  }
}

Future<bool> miruWriteFileBytes(String treePath, String fileName, Uint8List bytes) async {
  final path = p.join(treePath, fileName);
  // 用于写入外部文件（特指安卓/苹果）
  if (!Platform.isAndroid) {
    File(path).writeAsBytesSync(bytes);
    return true;
  } else {
    try {
      _saf.writeFileBytes(treePath, fileName, 'application/octet-stream', bytes);
      return true;
    } catch (e) {
      logger.warning('miruWriteFileBytes error: $e');
      return false;
    }
  }
}

(String, String) miruSplitPath(String path) {
  final split = p.split(path);
  return (p.joinAll(split.sublist(0, split.length - 1)), split.last);
}
