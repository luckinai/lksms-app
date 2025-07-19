import 'dart:async';
import 'package:get/get.dart';
import '../providers/sms_provider.dart';
import '../utils/logger.dart';
import '../services/api_client.dart';
import '../services/notification_service.dart';
import '../data/models/pending_task.dart';
import '../data/models/report_request.dart';
import '../data/repositories/settings_repository.dart';
import '../utils/constants.dart';

/// Isolate 通信服务
/// 负责处理前台任务和主 Isolate 之间的通信
class IsolateCommunicationService {
  static IsolateCommunicationService? _instance;
  static IsolateCommunicationService get instance {
    _instance ??= IsolateCommunicationService._();
    return _instance!;
  }
  
  IsolateCommunicationService._();

  // 消息监听器
  StreamSubscription? _messageSubscription;

  // 轮询状态控制
  bool _isPolling = false;

  /// 初始化通信服务
  void initialize() {
    AppLogger.info('初始化 Isolate 通信服务');

    // 重置轮询状态
    _isPolling = false;

    AppLogger.debug('Isolate 通信服务初始化完成');
  }

  /// 处理来自前台任务的消息
  void handleTaskMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      final type = message['type'] as String?;

      switch (type) {
        case 'TRIGGER_POLLING':
          _handlePollingTrigger(message);
          break;
        default:
          AppLogger.warning('未知的消息类型: $type');
      }
    }
  }

  /// 处理轮询触发请求
  void _handlePollingTrigger(Map<String, dynamic> message) {
    final timestamp = message['timestamp'] as int?;
    AppLogger.debug('收到轮询触发请求，时间戳: $timestamp');

    // 检查是否已有轮询在进行中
    if (_isPolling) {
      AppLogger.debug('轮询正在进行中，忽略本次触发');
      return;
    }

    // 执行轮询
    _executePolling();
  }

  /// 执行主线程轮询
  Future<void> _executePolling() async {
    if (_isPolling) {
      AppLogger.debug('轮询已在进行中，跳过');
      return;
    }

    _isPolling = true;

    try {
      AppLogger.info('开始执行主线程SMS任务轮询');

      // 1. 获取待发送任务
      final tasks = await _fetchPendingTasks();
      if (tasks.isEmpty) {
        AppLogger.debug('没有待发送的任务');
        return;
      }

      AppLogger.info('获取到 ${tasks.length} 个待发送任务');

      // 2. 逐条发送短信
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        AppLogger.debug('发送任务 ${i + 1}/${tasks.length}: ${task.phoneNumber}');

        try {
          // 发送短信
          await _sendSms(task.taskId, task.phoneNumber, task.content);

          // 发送间隔延迟
          if (i < tasks.length - 1) {
            final settings = await SettingsRepository.getSettings();
            final interval = settings?.sendInterval ?? AppConstants.defaultSendInterval;
            await Future.delayed(Duration(milliseconds: interval));
          }
        } catch (e) {
          AppLogger.error('发送任务 ${task.taskId} 异常', e);
          await _reportTaskResult(task.taskId, false, '发送异常: $e');
        }
      }

      AppLogger.info('本轮任务处理完成，共处理 ${tasks.length} 个任务');
    } catch (e) {
      AppLogger.error('主线程SMS任务轮询异常', e);
    } finally {
      _isPolling = false;
    }
  }

  /// 获取待发送任务
  Future<List<PendingTaskResponse>> _fetchPendingTasks() async {
    try {
      final settings = await SettingsRepository.getSettings();
      if (settings == null) {
        throw Exception('Settings not configured');
      }

      final response = await ApiClient.getPendingTasks(
        appId: settings.appId,
        limit: settings.taskLimit,
      );

      if (response.tasks.isNotEmpty) {
        AppLogger.info('获取到 ${response.tasks.length} 个待发送任务');
        return response.tasks;
      } else {
        AppLogger.debug('没有待发送的任务');
        return [];
      }
    } catch (e) {
      final errorMsg = '获取待发送任务失败: $e';
      AppLogger.error(errorMsg, e);

      // 通知界面API请求失败
      try {
        final notificationService = Get.find<NotificationService>();
        notificationService.showError(errorMsg);
      } catch (getError) {
        AppLogger.warning('无法显示通知: $getError');
      }

      return [];
    }
  }

  /// 发送短信
  Future<void> _sendSms(String taskId, String phoneNumber, String content) async {
    try {
      AppLogger.debug('开始发送短信到 $phoneNumber: $content');

      final result = await SmsProvider.sendSms(
        phoneNumber: phoneNumber,
        message: content,
      );

      if (result.success) {
        AppLogger.info('短信发送成功到 $phoneNumber');

        await _reportTaskResult(taskId, true, null);
      } else {
        final errorMsg = result.message;
        AppLogger.error('短信发送失败到 $phoneNumber: $errorMsg');

        // 通知界面短信发送失败
        try {
          final notificationService = Get.find<NotificationService>();
          notificationService.showSmsFailed(phoneNumber, errorMsg);
        } catch (getError) {
          AppLogger.warning('无法显示失败通知: $getError');
        }

        await _reportTaskResult(taskId, false, errorMsg);
      }
    } catch (e) {
      final errorMsg = '发送短信异常: $e';
      AppLogger.error('发送短信异常到 $phoneNumber', e);

      // 通知界面短信发送异常
      try {
        final notificationService = Get.find<NotificationService>();
        notificationService.showSmsFailed(phoneNumber, errorMsg);
      } catch (getError) {
        AppLogger.warning('无法显示异常通知: $getError');
      }

      await _reportTaskResult(taskId, false, errorMsg);
    }
  }

  /// 上报任务结果
  Future<void> _reportTaskResult(String taskId, bool success, String? errorMessage) async {
    try {
      final settings = await SettingsRepository.getSettings();
      if (settings == null) {
        throw Exception('Settings not configured');
      }

      final request = ReportRequest(
        taskId: taskId,
        appId: settings.appId,
        status: success ? AppConstants.reportStatusSuccess : AppConstants.reportStatusFailed,
        errorMessage: errorMessage,
        shouldRetry: success ? false : true,
      );

      await ApiClient.reportResult(request);
      AppLogger.debug('任务结果上报成功: $taskId');

    } catch (e) {
      final errorMsg = '上报任务结果失败: $e';
      AppLogger.error(errorMsg, e);

      // 通知界面API上报失败
      try {
        final notificationService = Get.find<NotificationService>();
        notificationService.showError('任务结果上报失败，请检查网络连接');
      } catch (getError) {
        AppLogger.warning('无法显示上报失败通知: $getError');
      }
    }
  }

  /// 清理资源
  void dispose() {
    _messageSubscription?.cancel();
    _isPolling = false;
    AppLogger.info('Isolate 通信服务已清理');
  }
}
