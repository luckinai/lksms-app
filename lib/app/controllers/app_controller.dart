import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lksms_app/app/providers/sms_provider.dart';
import 'dart:async';

import '../data/repositories/settings_repository.dart';
import '../services/notification_service.dart';
import '../services/foreground_service.dart';
import '../utils/logger.dart';

class AppController extends GetxController {
  // late final SettingsRepository _settingsRepository;
  late final NotificationService _notificationService;
  late final ForegroundService _foregroundService;
  // late final SmsService _smsService;

  // 响应式状态
  final RxBool _isServiceRunning = false.obs;
  final RxBool _isNetworkConnected = true.obs;
  // final RxBool _hasSmsPermission = false.obs;
  final RxBool _isInitialized = false.obs;

  // 网络连接监听
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Getters
  bool get isServiceRunning => _isServiceRunning.value;
  bool get isNetworkConnected => _isNetworkConnected.value;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    _initializeApp();
  }

  void _initializeDependencies() {
    _notificationService = Get.find<NotificationService>();
    _foregroundService = Get.find<ForegroundService>();
  }

  Future<void> _initializeApp() async {
    try {
      // 检查网络连接
      await _checkNetworkConnection();

      // 监听网络变化
      _startNetworkMonitoring();

      // 检查前台服务状态
      await _checkForegroundServiceStatus();

      _isInitialized.value = true;

      AppLogger.info('App initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing app', e);
      _notificationService.showError('应用初始化失败: $e');
    }
  }

  // 检查网络连接
  Future<void> _checkNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isNetworkConnected.value = connectivityResult != ConnectivityResult.none;
    } catch (e) {
      AppLogger.error('Error checking network connection', e);
      _isNetworkConnected.value = false;
    }
  }

  // 监听网络变化
  void _startNetworkMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasConnected = _isNetworkConnected.value;
        _isNetworkConnected.value = result != ConnectivityResult.none;

        if (wasConnected != _isNetworkConnected.value) {
          _notificationService.showNetworkStatus(_isNetworkConnected.value);
        }
      },
    );
  }

  // 请求短信权限
  Future<bool> requestSmsPermission() async {
    // return await SmsProvider.requestSmsPermission();
    final granted = await SmsProvider.checkSmsPermission();
    if (!granted) {
      return await SmsProvider.requestSmsPermission();
    }
    return true;
  }

  // 检查前台服务状态
  Future<void> _checkForegroundServiceStatus() async {
    try {
      _isServiceRunning.value = await _foregroundService.isServiceRunning();
    } catch (e) {
      AppLogger.error('Error checking foreground service status', e);
      _isServiceRunning.value = false;
    }
  }

  // 启动服务
  Future<bool> startService() async {
    // 检查设置是否配置
    final isConfigured = await SettingsRepository.isConfigured();
    if (!isConfigured) {
      _notificationService.showError('请先配置服务器设置');
      return false;
    }
    final granted = await requestSmsPermission();
    if (!granted) {
      _notificationService.showError('无短信发送权限');
      return false;
    }
    try {
      // 启动前台服务
      final started = await _foregroundService.startForegroundService();
      if (started) {
        _isServiceRunning.value = true;
        _notificationService.showServiceStatus(true);
        return true;
      } else {
        _notificationService.showError('启动前台服务失败');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error starting service', e);
      _notificationService.showError('启动服务失败: $e');
      return false;
    }
  }

  // 停止服务
  Future<bool> stopService() async {
    try {
      final stopped = await _foregroundService.stopForegroundService();
      if (stopped) {
        _isServiceRunning.value = false;
        _notificationService.showServiceStatus(false);
        return true;
      } else {
        _notificationService.showError('停止前台服务失败');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error stopping service', e);
      _notificationService.showError('停止服务失败: $e');
      return false;
    }
  }

  // 切换服务状态
  Future<void> toggleService() async {
    if (_isServiceRunning.value) {
      await stopService();
    } else {
      await startService();
    }
  }

  // 刷新应用状态
  Future<void> refreshAppStatus() async {
    await _checkNetworkConnection();
    // await _checkSmsPermission();
    await _checkForegroundServiceStatus();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
