import 'dart:isolate';
import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../utils/logger.dart';
import '../data/repositories/settings_repository.dart';

// 前台任务处理器
class SmsTaskHandler extends TaskHandler {
  // 从配置中获取的参数
  String? _baseUrl;
  String? _appId;
  int? _taskLimit;
  int? _sendInterval;

  // 默认值
  static const String _defaultBaseUrl = '';
  static const String _defaultAppId = '';
  static const int _defaultTaskLimit = 10;
  static const int _defaultSendInterval = 1000;

  // 与主 Isolate 通信的 SendPort
  SendPort? _mainSendPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    AppLogger.info('SMS前台任务已启动: $timestamp');
    await _loadConfiguration();

    // 设置与主 Isolate 的通信
    _mainSendPort = sendPort;

    // 等待主线程通信服务初始化完成
    // 延迟3秒确保主线程的 IsolateCommunicationService 已经初始化
    await Future.delayed(const Duration(seconds: 3));
    AppLogger.debug('前台任务初始化延迟完成，准备开始轮询');
  }

  // 加载配置
  Future<void> _loadConfiguration() async {
    try {
      // 从 SettingsRepository 加载配置
      final settings = await SettingsRepository.getSettings();

      if (settings != null) {
        _baseUrl = settings.getApiUrl(''); // 获取基础 API URL
        _appId = settings.appId;
        _taskLimit = settings.taskLimit;
        _sendInterval = settings.sendInterval;

        AppLogger.info(
            '配置加载完成: baseUrl=$_baseUrl, appId=$_appId, taskLimit=$_taskLimit, sendInterval=$_sendInterval');
      } else {
        AppLogger.warning('未找到配置，使用默认值');
        _useDefaultConfiguration();
      }
    } catch (e) {
      AppLogger.error('加载配置失败，使用默认值', e);
      _useDefaultConfiguration();
    }
  }

  void _useDefaultConfiguration() {
    _baseUrl = _defaultBaseUrl;
    _appId = _defaultAppId;
    _taskLimit = _defaultTaskLimit;
    _sendInterval = _defaultSendInterval;
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    AppLogger.debug('触发SMS任务轮询事件: $timestamp');

    // 通过 SendPort 通知主线程执行轮询
    if (_mainSendPort != null) {
      _mainSendPort!.send({
        'type': 'TRIGGER_POLLING',
        'timestamp': timestamp.millisecondsSinceEpoch,
      });
      AppLogger.debug('已发送轮询触发消息到主线程');
    } else {
      // 如果通信端口未建立，尝试重新设置
      if (sendPort != null) {
        AppLogger.debug('尝试重新建立主线程通信端口');
        _mainSendPort = sendPort;
        // 重新尝试发送消息
        _mainSendPort!.send({
          'type': 'TRIGGER_POLLING',
          'timestamp': timestamp.millisecondsSinceEpoch,
        });
        AppLogger.debug('重新建立通信端口后发送轮询触发消息');
      } else {
        AppLogger.warning('无法触发轮询：主线程通信端口未建立且无法重新建立');
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    AppLogger.info('SMS前台任务已销毁: $timestamp');
  }





  @override
  void onNotificationButtonPressed(String id) {
    AppLogger.info('通知按钮被点击: $id');
  }

  @override
  void onNotificationPressed() {
    AppLogger.info('通知被点击');
    FlutterForegroundTask.launchApp('/');
  }






}
