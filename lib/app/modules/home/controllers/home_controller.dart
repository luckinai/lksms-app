import 'package:get/get.dart';

import '../../../controllers/app_controller.dart';
import '../../../services/notification_service.dart';
import '../../../providers/sms_provider.dart';
import '../../../utils/logger.dart';

class HomeController extends GetxController {
  late final AppController _appController;
  late final NotificationService _notificationService;

  // 响应式状态
  final RxBool _isLoading = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isServiceRunning => _appController.isServiceRunning;
  bool get isNetworkConnected => _appController.isNetworkConnected;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
  }

  void _initializeDependencies() {
    _appController = Get.find<AppController>();
    _notificationService = Get.find<NotificationService>();
  }


  // 切换服务状态
  Future<void> toggleService() async {
    _isLoading.value = true;
    try {
      await _appController.toggleService();
    } catch (e) {
      AppLogger.error('Error toggling service', e);
      _notificationService.showError('切换服务状态失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 测试原生短信功能
  Future<void> test() async {
    _isLoading.value = true;
    try {
      // 1. 检查权限
      final hasPermission = await SmsProvider.checkSmsPermission();
      if (!hasPermission) {
        _notificationService.showWarning('正在请求短信权限...');
        final granted = await SmsProvider.requestSmsPermission();
        if (!granted) {
          _notificationService.showError('短信权限被拒绝，无法发送短信');
          return;
        }
      }

      // 2. 获取SIM卡信息
      final simCards = await SmsProvider.getSimCardInfo();
      AppLogger.info('检测到 ${simCards.length} 张SIM卡');

      // 3. 发送测试短信
      const testPhoneNumber = '13800138000'; // 使用运营商客服号码测试
      const testMessage = '这是通过原生MethodChannel发送的测试短信';

      _notificationService.showInfo('正在发送测试短信到 $testPhoneNumber...');

      final result = await SmsProvider.sendSms(
        phoneNumber: testPhoneNumber,
        message: testMessage,
        subscriptionId:
            simCards.isNotEmpty ? simCards[0]['subscriptionId'] : -1,
      );

      // 4. 处理结果
      if (result.success) {
        _notificationService.showSuccess('短信发送成功: ${result.message}');
        AppLogger.info('短信发送成功: ${result.message}');
      } else {
        _notificationService.showError('短信发送失败: ${result.message}');
        AppLogger.error('短信发送失败', result.message);
      }
    } catch (e) {
      AppLogger.error('Error in native SMS test', e);
      _notificationService.showError('原生短信测试失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 刷新状态
  Future<void> refreshStatus() async {
    _isLoading.value = true;
    try {
      await _appController.refreshAppStatus();
      // await _smsServiceController.refreshTasks();
      // _notificationService.showSuccess('状态已刷新');
    } catch (e) {
      AppLogger.error('Error refreshing status', e);
      _notificationService.showError('刷新状态失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 导航到设置页面
  void goToSettings() {
    Get.toNamed('/settings');
  }

  // 导航到统计页面
  void goToStatistics() {
    Get.toNamed('/statistics');
  }

  // 获取服务状态文本
  String getServiceStatusText() {
    if (!_appController.isNetworkConnected) {
      return '网络未连接';
    }

    // if (!_appController.hasSmsPermission) {
    //   return '缺少短信权限';
    // }

    if (_appController.isServiceRunning) {
      // if (_smsServiceController.isPolling) {
      //   return '服务运行中 - 轮询任务';
      // } else {
      //   return '服务运行中 - 待机';
      // }
      return '服务运行中';
    } else {
      return '服务已停止';
    }
  }

  // 获取服务状态颜色
  int getServiceStatusColor() {
    if (!_appController.isNetworkConnected) {
      // || !_appController.hasSmsPermission) {
      return 0xFFFF9800; // Orange
    }

    if (_appController.isServiceRunning) {
      return 0xFF4CAF50; // Green
    } else {
      return 0xFFF44336; // Red
    }
  }
}
