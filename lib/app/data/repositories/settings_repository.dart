import '../models/app_settings.dart';
import '../../providers/storage_provider.dart';
import '../../utils/constants.dart';
import '../../utils/logger.dart';

class SettingsRepository {
  // 获取应用设置
  static Future<AppSettings?> getSettings() async {
    try {
      await StorageProvider.init(); // 确保已初始化
      final data = StorageProvider.read<Map<String, dynamic>>(
        AppConstants.storageKeySettings,
      );

      if (data != null) {
        return AppSettings.fromJson(data);
      }

      return null;
    } catch (e) {
      AppLogger.error('Error getting settings', e);
      return null;
    }
  }

  // 保存应用设置
  static Future<bool> saveSettings(AppSettings settings) async {
    try {
      await StorageProvider.init(); // 确保已初始化
      await StorageProvider.write(
        AppConstants.storageKeySettings,
        settings.toJson(),
      );
      return true;
    } catch (e) {
      AppLogger.error('Error saving settings', e);
      return false;
    }
  }

  // // 获取设置或默认设置
  // Future<AppSettings> getSettingsOrDefault() async {
  //   final settings = await getSettings();
  //   return settings ?? AppSettings.defaultSettings();
  // }

  // // 更新特定设置字段
  // Future<bool> updateSetting<T>(String field, T value) async {
  //   try {
  //     final currentSettings = await getSettingsOrDefault();
  //     AppSettings updatedSettings;

  //     switch (field) {
  //       case 'serverUrl':
  //         updatedSettings = currentSettings.copyWith(serverUrl: value as String);
  //         break;
  //       case 'appId':
  //         updatedSettings = currentSettings.copyWith(appId: value as String);
  //         break;
  //       case 'username':
  //         updatedSettings = currentSettings.copyWith(username: value as String);
  //         break;
  //       case 'password':
  //         updatedSettings = currentSettings.copyWith(password: value as String);
  //         break;
  //       case 'pollingInterval':
  //         updatedSettings = currentSettings.copyWith(pollingInterval: value as int);
  //         break;
  //       case 'taskLimit':
  //         updatedSettings = currentSettings.copyWith(taskLimit: value as int);
  //         break;
  //       case 'sendInterval':
  //         updatedSettings = currentSettings.copyWith(sendInterval: value as int);
  //         break;
  //       default:
  //         return false;
  //     }

  //     return await saveSettings(updatedSettings);
  //   } catch (e) {
  //     AppLogger.error('Error updating setting $field', e);
  //     return false;
  //   }
  // }

  // 重置设置为默认值
  static Future<bool> resetSettings() async {
    try {
      await StorageProvider.init(); // 确保已初始化
      await StorageProvider.remove(AppConstants.storageKeySettings);
      return true;
    } catch (e) {
      AppLogger.error('Error resetting settings', e);
      return false;
    }
  }

  // 检查设置是否已配置
  static Future<bool> isConfigured() async {
    final settings = await getSettings();
    return settings?.isValid ?? false;
  }

  // 导出设置
  // Future<Map<String, dynamic>?> exportSettings() async {
  //   try {
  //     final settings = await getSettings();
  //     return settings?.toJson();
  //   } catch (e) {
  //     AppLogger.error('Error exporting settings', e);
  //     return null;
  //   }
  // }

  // // 导入设置
  // Future<bool> importSettings(Map<String, dynamic> data) async {
  //   try {
  //     final settings = AppSettings.fromJson(data);
  //     return await saveSettings(settings);
  //   } catch (e) {
  //     AppLogger.error('Error importing settings', e);
  //     return false;
  //   }
  // }

  // 注意：静态类不支持监听功能
  // 如需监听设置变化，请在应用层实现
}
