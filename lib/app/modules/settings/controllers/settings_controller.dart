import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../utils/logger.dart';

class SettingsController extends GetxController {
  // 响应式变量
  final RxBool isLoading = false.obs;
  final Rx<AppSettings> settings = AppSettings.defaultSettings().obs;
  final RxString appVersion = ''.obs;
  final RxString buildNumber = ''.obs;

  // 临时设置变量
  final RxString tempServerUrl = ''.obs;
  final RxString tempAppId = ''.obs;
  final RxString tempUsername = ''.obs;
  final RxString tempPassword = ''.obs;
  final RxInt tempPollingInterval = 5.obs;
  final RxInt tempTaskLimit = 1.obs;
  final RxInt tempSendInterval = 1000.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadAppInfo();
    AppLogger.info('SettingsController initialized');
  }

  // 加载设置
  Future<void> _loadSettings() async {
    isLoading.value = true;
    try {
      final currentSettings = await SettingsRepository.getSettings() ?? AppSettings.defaultSettings();
      settings.value = currentSettings;

      // 更新临时变量
      tempServerUrl.value = currentSettings.serverUrl;
      tempAppId.value = currentSettings.appId;
      tempUsername.value = currentSettings.username;
      tempPassword.value = currentSettings.password;
      tempPollingInterval.value = currentSettings.pollingInterval;
      tempTaskLimit.value = currentSettings.taskLimit;
      tempSendInterval.value = currentSettings.sendInterval;

      AppLogger.info('设置加载成功');
    } catch (e) {
      AppLogger.error('加载设置失败', e);
    } finally {
      isLoading.value = false;
    }
  }

  // 加载应用信息
  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
      buildNumber.value = packageInfo.buildNumber;
    } catch (e) {
      AppLogger.error('加载应用信息失败', e);
      appVersion.value = '未知';
      buildNumber.value = '未知';
    }
  }

  // 保存设置
  Future<void> saveSettings() async {
    isLoading.value = true;
    try {
      final newSettings = AppSettings(
        serverUrl: tempServerUrl.value,
        appId: tempAppId.value,
        username: tempUsername.value,
        password: tempPassword.value,
        pollingInterval: tempPollingInterval.value,
        taskLimit: tempTaskLimit.value,
        sendInterval: tempSendInterval.value,
      );

      await SettingsRepository.saveSettings(newSettings);
      settings.value = newSettings;

      // 应用设置到相关控制器
      // await _appController.updateSettings(newSettings);

      Get.snackbar(
        '保存成功',
        '设置已保存并应用',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      AppLogger.info('设置保存成功');
    } catch (e) {
      AppLogger.error('保存设置失败', e);
      Get.snackbar(
        '保存失败',
        '设置保存失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 重置设置
  Future<void> resetSettings() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要重置所有设置为默认值吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('重置'),
          ),
        ],
      ),
    );

    if (result == true) {
      isLoading.value = true;
      try {
        final defaultSettings = AppSettings.defaultSettings();
        await SettingsRepository.saveSettings(defaultSettings);
        settings.value = defaultSettings;

        // 更新临时变量
        tempServerUrl.value = defaultSettings.serverUrl;
        tempAppId.value = defaultSettings.appId;
        tempUsername.value = defaultSettings.username;
        tempPassword.value = defaultSettings.password;
        tempPollingInterval.value = defaultSettings.pollingInterval;
        tempTaskLimit.value = defaultSettings.taskLimit;
        tempSendInterval.value = defaultSettings.sendInterval;

        // 应用设置到相关控制器
        // await _appController.updateSettings(defaultSettings);

        Get.snackbar(
          '重置成功',
          '设置已重置为默认值',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        AppLogger.info('设置重置成功');
      } catch (e) {
        AppLogger.error('重置设置失败', e);
        Get.snackbar(
          '重置失败',
          '设置重置失败: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // 关于应用
  void showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('关于 LKSMS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: ${appVersion.value}'),
            Text('构建号: ${buildNumber.value}'),
            const SizedBox(height: 16),
            const Text('LKSMS 是一个短信发送应用。'),
            const SizedBox(height: 16),
            const Text('© 2024 LKSMS Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
