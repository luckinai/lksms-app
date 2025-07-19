import 'dart:io';
import 'dart:isolate';
import 'package:get/get.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:lksms_app/app/services/sms_task_handler.dart';

import '../utils/constants.dart';
import '../utils/logger.dart';
import 'isolate_communication_service.dart';

class ForegroundService extends GetxService {
  // 用于接收前台任务消息的 ReceivePort
  ReceivePort? _receivePort;

  @override
  void onInit() {
    super.onInit();
    _initializeForegroundTask();
    _initializeCommunication();
  }

  void _initializeCommunication() {
    // 初始化通信服务
    IsolateCommunicationService.instance.initialize();
  }

  void _initializeForegroundTask() {
    // 使用系统轮询间隔（默认5秒，可以从设置中获取）
    const pollingInterval = AppConstants.defaultPollingInterval * 1000; // 转换为毫秒

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: AppConstants.foregroundChannelId,
        channelName: AppConstants.foregroundChannelName,
        channelDescription: 'LKSMS前台服务通知',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: pollingInterval,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // 启动前台服务
  Future<bool> startForegroundService() async {
    if (!await _requestPermissionForAndroid()) {
      return false;
    }
    try {
      // // 检查通知权限
      // if (!await _checkNotificationPermission()) {
      //   return false;
      // }

      // // 检查悬浮窗权限
      // if (!await _checkOverlayPermission()) {
      //   return false;
      // }

      // 确保通信服务已初始化
      AppLogger.debug('确保通信服务已初始化');
      IsolateCommunicationService.instance.initialize();

      // 等待一小段时间确保初始化完成
      await Future.delayed(const Duration(milliseconds: 500));

      // 启动前台任务
      await FlutterForegroundTask.startService(
        notificationTitle: 'LKSMS服务运行中',
        notificationText: '正在监听短信发送任务',
        callback: startCallback,
      );

      // 设置通信端口监听
      _receivePort = FlutterForegroundTask.receivePort;
      _receivePort?.listen((message) {
        IsolateCommunicationService.instance.handleTaskMessage(message);
      });

      AppLogger.info('前台服务启动成功');
      return true;
    } catch (e) {
      AppLogger.error('启动前台服务失败', e);
      return false;
    }
  }

  ///启动前台服务需要一系列的授权
  Future<bool> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return false;
    }
    if (!await FlutterForegroundTask.canDrawOverlays) {
      ///打开设置页面，您可以在其中允许拒绝“android.permission.SYSTEM_ALERT_WINDOW”权限。传递“forceOpen”布尔值以打开权限页面，即使已授予。
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        return false;
      }
    }

    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      //判断是否开启排除电池优化权限，如果没有开启去开启
      final isGranted =
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      if (!isGranted) {
        return false;
      }
    }

    ///检查前台服务权限授予的状态
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      //没有授予先去请求
      final isGranted =
          await FlutterForegroundTask.requestNotificationPermission();
      if (isGranted != NotificationPermission.granted) {
        return false;
      }
    }
    return true;
  }
  
  // 停止前台服务
  Future<bool> stopForegroundService() async {
    try {
      // 清理通信服务
      IsolateCommunicationService.instance.dispose();
      _receivePort = null;

      return await FlutterForegroundTask.stopService();
    } catch (e) {
      AppLogger.error('Failed to stop foreground service', e);
      return false;
    }
  }

  // 更新前台服务通知
  Future<void> updateNotification({
    required String title,
    required String text,
  }) async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
    } catch (e) {
      AppLogger.error('Failed to update notification', e);
    }
  }

  // 检查前台服务是否运行
  Future<bool> isServiceRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  // 请求忽略电池优化权限
  Future<bool> requestIgnoreBatteryOptimization() async {
    try {
      return await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    } catch (e) {
      AppLogger.error('Failed to request ignore battery optimization', e);
      return false;
    }
  }
}

// 前台任务回调函数
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SmsTaskHandler());
}