import 'package:fluent_ui/fluent_ui.dart';
import 'package:isar/isar.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/extension_setting.dart';
import 'package:miru_app/models/favorite.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';

class DatabaseUtils {
  static final db = MiruStorage.database;

  static toggleFavorite({
    required String package,
    required String url,
    required String cover,
    required String name,
  }) async {
    final ext = ExtensionUtils.extensions[package];
    if (ext == null) {
      throw Exception('extension not found');
    }
    final extension = ext.extension;
    return db.writeTxn(() async {
      if (await isFavorite(
        package: extension.package,
        url: url,
      )) {
        return db.favorites
            .filter()
            .packageEqualTo(extension.package)
            .and()
            .urlEqualTo(url)
            .deleteAll();
      } else {
        return db.favorites.put(
          Favorite()
            ..cover = cover
            ..title = name
            ..package = extension.package
            ..type = extension.type
            ..url = url,
        );
      }
    });
  }

  static Future<bool> isFavorite({
    required String package,
    required String url,
  }) async {
    return (await db.favorites
            .filter()
            .packageEqualTo(package)
            .and()
            .urlEqualTo(url)
            .findFirst()) !=
        null;
  }

  static Future<List<Favorite>> getFavoritesByType(
      {ExtensionType? type}) async {
    if (type == null) {
      return db.favorites.where().sortByDateDesc().findAll();
    }
    return db.favorites.filter().typeEqualTo(type).sortByDateDesc().findAll();
  }

  // 历史记录

  static Future<List<History>> getHistorysByType({ExtensionType? type}) async {
    if (type == null) {
      return db.historys.where().sortByDateDesc().findAll();
    }
    return db.historys.filter().typeEqualTo(type).sortByDateDesc().findAll();
  }

  static Future<History?> getHistoryByPackageAndUrl(
      String package, String url) async {
    return db.historys
        .filter()
        .packageEqualTo(package)
        .and()
        .urlEqualTo(url)
        .findFirst();
  }

  // 更新历史

  static Future<Id> putHistory(History history) async {
    // 判断是否存在，存在则更新
    final hst = await getHistoryByPackageAndUrl(history.package, history.url);
    if (hst != null) {
      hst
        ..date = DateTime.now()
        ..cover = history.cover
        ..title = history.title
        ..episodeGroupId = history.episodeGroupId
        ..episodeId = history.episodeId
        ..episodeTitle = history.episodeTitle;
      return db.writeTxn(() => db.historys.put(hst));
    }

    return db.writeTxn(() => db.historys.put(history));
  }

  // 扩展设置
  // 获取扩展设置
  static Future<List<ExtensionSetting>> getExtensionSettings(String package) {
    return db.extensionSettings.filter().packageEqualTo(package).findAll();
  }

  // 更新扩展设置
  static Future<Id?> putExtensionSetting(
      String package, String key, String value) async {
    final extensionSetting = await getExtensionSetting(package, key);
    if (extensionSetting == null) {
      return null;
    }
    extensionSetting.value = value;
    debugPrint(extensionSetting.value);
    return db.writeTxn(() => db.extensionSettings.put(extensionSetting));
  }

  // 获取扩展设置
  static Future<ExtensionSetting?> getExtensionSetting(
      String package, String key) async {
    return db.extensionSettings
        .filter()
        .packageEqualTo(package)
        .and()
        .keyEqualTo(key)
        .findFirst();
  }

  // 添加扩展设置
  static Future<Id> registerExtensionSetting(
    ExtensionSetting extensionSetting,
  ) async {
    if (extensionSetting.type == ExtensionSettingType.radio &&
        extensionSetting.options == null) {
      throw Exception('options is null');
    }

    final extSetting = await getExtensionSetting(
        extensionSetting.package, extensionSetting.key);
    // 如果不存在相同设置，则添加
    if (extSetting == null) {
      return db.writeTxn(() => db.extensionSettings.put(extensionSetting));
    }

    extSetting.defaultValue = extensionSetting.defaultValue;

    // 如果类型不同，重置值
    if (extSetting.type != extensionSetting.type) {
      extSetting.type = extensionSetting.type;
      extSetting.value = extensionSetting.defaultValue;
    }
    extSetting.defaultValue = extensionSetting.defaultValue;
    extSetting.description = extensionSetting.description;
    extSetting.options = extensionSetting.options;
    extSetting.title = extensionSetting.title;
    return db.writeTxn(() => db.extensionSettings.put(extSetting));
  }

  // 删除扩展设置
  static Future<void> deleteExtensionSetting(String package) async {
    return db.writeTxn(
      () => db.extensionSettings.filter().packageEqualTo(package).deleteAll(),
    );
  }

  // 清理不需要的扩展设置
  static Future<void> cleanExtensionSettings(
    String package,
    List<String> keys,
  ) async {
    // 需要删除的 id;
    final ids = <int>[];

    final extSettings =
        await db.extensionSettings.filter().packageEqualTo(package).findAll();

    for (final extSetting in extSettings) {
      if (!keys.contains(extSetting.key)) {
        ids.add(extSetting.id);
      }
    }

    return db.writeTxn(() => db.extensionSettings.deleteAll(ids));
  }
}
