import 'package:get_storage/get_storage.dart';
import '../utils/logger.dart';

class StorageProvider {
  static GetStorage? _box;

  // 初始化存储
  static Future<void> init() async {
    if (_box == null) {
      await GetStorage.init();
      _box = GetStorage();
      AppLogger.info('Storage provider initialized');
    }
  }

  // 获取存储实例
  static GetStorage get _storage {
    if (_box == null) {
      throw Exception('StorageProvider not initialized. Call StorageProvider.init() first.');
    }
    return _box!;
  }

  // 读取数据
  static T? read<T>(String key) {
    try {
      return _storage.read<T>(key);
    } catch (e) {
      AppLogger.error('Error reading key $key', e);
      return null;
    }
  }

  // 写入数据
  static Future<void> write(String key, dynamic value) async {
    try {
      await _storage.write(key, value);
    } catch (e) {
      AppLogger.error('Error writing key $key', e);
      rethrow;
    }
  }

  // 删除数据
  static Future<void> remove(String key) async {
    try {
      await _storage.remove(key);
    } catch (e) {
      AppLogger.error('Error removing key $key', e);
      rethrow;
    }
  }

  // 清空所有数据
  static Future<void> clear() async {
    try {
      await _storage.erase();
    } catch (e) {
      AppLogger.error('Error clearing storage', e);
      rethrow;
    }
  }

  // 检查键是否存在
  static bool hasKey(String key) {
    try {
      return _storage.hasData(key);
    } catch (e) {
      AppLogger.error('Error checking key $key', e);
      return false;
    }
  }

  // 获取所有键
  static Iterable<String> getKeys() {
    try {
      return _storage.getKeys() ?? [];
    } catch (e) {
      AppLogger.error('Error getting keys', e);
      return [];
    }
  }

  // 监听存储变化
  static void listen(Function() callback) {
    try {
      _storage.listen(callback);
    } catch (e) {
      AppLogger.error('Error setting up storage listener', e);
    }
  }

  // // 批量写入
  // Future<void> writeAll(Map<String, dynamic> data) async {
  //   try {
  //     for (final entry in data.entries) {
  //       await _box?.write(entry.key, entry.value);
  //     }
  //   } catch (e) {
  //     AppLogger.error('Error writing batch data', e);
  //     rethrow;
  //   }
  // }

  // // 批量读取
  // Map<String, dynamic> readAll(List<String> keys) {
  //   Map<String, dynamic> result = {};
  //   try {
  //     for (final key in keys) {
  //       final value = _box?.read(key);
  //       if (value != null) {
  //         result[key] = value;
  //       }
  //     }
  //   } catch (e) {
  //     AppLogger.error('Error reading batch data', e);
  //   }
  //   return result;
  // }
}
