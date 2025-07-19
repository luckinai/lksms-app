import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationService extends GetxService {

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    // 初始化通知服务
    // 这里可以添加本地通知的初始化代码
  }

  // 显示成功通知
  void showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // 显示错误通知
  void showError(String message) {
    Get.snackbar(
      '错误',
      message,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  // 显示警告通知
  void showWarning(String message) {
    Get.snackbar(
      '警告',
      message,
      icon: const Icon(Icons.warning, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // 显示信息通知
  void showInfo(String message) {
    Get.snackbar(
      '信息',
      message,
      icon: const Icon(Icons.info, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // 显示短信发送成功通知
  void showSmsSent(String phoneNumber) {
    showSuccess('短信已发送至 $phoneNumber');
  }

  // 显示短信发送失败通知
  void showSmsFailed(String phoneNumber, String error) {
    showError('发送至 $phoneNumber 失败: $error');
  }

  // 显示服务状态通知
  void showServiceStatus(bool isRunning) {
    if (isRunning) {
      showSuccess('短信服务已启动');
    } else {
      showInfo('短信服务已停止');
    }
  }

  // 显示网络连接状态通知
  void showNetworkStatus(bool isConnected) {
    if (isConnected) {
      showSuccess('网络连接正常');
    } else {
      showError('网络连接失败');
    }
  }

  // 显示设置保存通知
  void showSettingsSaved() {
    showSuccess('设置已保存');
  }

  // 显示权限请求通知
  void showPermissionDenied(String permission) {
    showError('缺少$permission权限，请在设置中开启');
  }
}
