import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 短信发送状态
enum SmsStatus {
  sent,      // 发送成功
  delivered, // 已送达
  failed,    // 发送失败
  pending,   // 发送中
}

/// 短信发送结果
class SmsResult {
  final bool success;
  final String message;
  final SmsStatus? status;
  final String? errorCode;

  SmsResult({
    required this.success,
    required this.message,
    this.status,
    this.errorCode,
  });

  factory SmsResult.fromMap(Map<String, dynamic> map) {
    return SmsResult(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      status: map['status'] != null ? _parseStatus(map['status']) : null,
      errorCode: map['errorCode'],
    );
  }

  static SmsStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return SmsStatus.sent;
      case 'delivered':
        return SmsStatus.delivered;
      case 'failed':
        return SmsStatus.failed;
      case 'pending':
        return SmsStatus.pending;
      default:
        return SmsStatus.failed;
    }
  }
}

/// 原生短信服务类
/// 通过 MethodChannel 调用 Android 原生短信功能
class SmsProvider {
  static const MethodChannel _channel = MethodChannel('com.example.lksms/sms');
  static bool _isInitialized = false;

  /// 初始化服务
  static void initialize() {
    if (!_isInitialized) {
      _setupMethodCallHandler();
      _isInitialized = true;
    }
  }

  /// 设置方法调用处理器，用于接收 Android 端的回调
  static void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onSmsStatusChanged':
          _handleSmsStatusChanged(call.arguments);
          break;
        case 'onPermissionResult':
          _handlePermissionResult(call.arguments);
          break;
        default:
          print('未知的方法调用: ${call.method}');
      }
    });
  }

  /// 处理短信状态变化回调
  static void _handleSmsStatusChanged(dynamic arguments) {
    if (arguments is Map<String, dynamic>) {
      final result = SmsResult.fromMap(arguments);
      print('短信状态变化: ${result.message}, 状态: ${result.status}');
      // 这里可以发送事件通知 UI 更新
      // try {
      //   Get.find<SmsController>().updateSmsStatus(result);
      // } catch (e) {
      //   print('SmsController not found: $e');
      // }
    }
  }

  /// 处理权限结果回调
  static void _handlePermissionResult(dynamic arguments) {
    if (arguments is Map<String, dynamic>) {
      final granted = arguments['granted'] ?? false;
      final permission = arguments['permission'] ?? '';
      print('权限结果: $permission = $granted');
    }
  }
  
  /// 检查短信权限
  static Future<bool> checkSmsPermission() async {
    initialize(); // 确保已初始化
    try {
      final result = await _channel.invokeMethod('checkSmsPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('检查短信权限失败: ${e.message}');
      return false;
    }
  }

  /// 请求短信权限
  static Future<bool> requestSmsPermission() async {
    initialize(); // 确保已初始化
    try {
      final result = await _channel.invokeMethod('requestSmsPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('请求短信权限失败: ${e.message}');
      return false;
    }
  }
  
  /// 发送短信
  /// [phoneNumber] 手机号码
  /// [message] 短信内容
  /// [subscriptionId] SIM卡订阅ID（双卡手机使用，-1表示默认卡）
  static Future<SmsResult> sendSms({
    required String phoneNumber,
    required String message,
    int subscriptionId = -1,
  }) async {
    initialize(); // 确保已初始化
    try {
      // 参数验证
      if (phoneNumber.isEmpty) {
        return SmsResult(
          success: false,
          message: '手机号码不能为空',
          errorCode: 'INVALID_PHONE_NUMBER',
        );
      }

      if (message.isEmpty) {
        return SmsResult(
          success: false,
          message: '短信内容不能为空',
          errorCode: 'INVALID_MESSAGE',
        );
      }

      // 调用 Android 原生方法
      final result = await _channel.invokeMethod('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
        'subscriptionId': subscriptionId,
      });

      if (result is Map) {
        // 将 Map<String, Object?> 转换为 Map<String, dynamic>
        final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
        return SmsResult.fromMap(resultMap);
      } else {
        return SmsResult(
          success: false,
          message: '发送失败：返回数据格式错误 (${result.runtimeType})',
          errorCode: 'INVALID_RESPONSE',
        );
      }
    } on PlatformException catch (e) {
      return SmsResult(
        success: false,
        message: '发送失败：${e.message}',
        errorCode: e.code,
      );
    } catch (e) {
      return SmsResult(
        success: false,
        message: '发送失败：$e',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }
  
  /// 批量发送短信
  /// [contacts] 联系人列表，每个元素包含 phoneNumber 和 message
  static Future<List<SmsResult>> sendBatchSms(List<Map<String, String>> contacts) async {
    List<SmsResult> results = [];

    for (var contact in contacts) {
      final phoneNumber = contact['phoneNumber'] ?? '';
      final message = contact['message'] ?? '';

      final result = await sendSms(
        phoneNumber: phoneNumber,
        message: message,
      );

      results.add(result);

      // 添加延迟避免发送过快
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }

  /// 获取SIM卡信息
  static Future<List<Map<String, dynamic>>> getSimCardInfo() async {
    initialize(); // 确保已初始化
    try {
      final result = await _channel.invokeMethod('getSimCardInfo');
      if (result is List) {
        return result.cast<Map<String, dynamic>>();
      }
      return [];
    } on PlatformException catch (e) {
      print('获取SIM卡信息失败: ${e.message}');
      return [];
    }
  }
}

/// 短信控制器，用于管理短信发送状态
class SmsController extends GetxController {
  final RxList<SmsResult> _smsHistory = <SmsResult>[].obs;
  final RxBool _isSending = false.obs;

  RxList<SmsResult> get smsHistory => _smsHistory;
  bool get isSending => _isSending.value;
  
  /// 更新短信状态
  void updateSmsStatus(SmsResult result) {
    _smsHistory.add(result);
  }
  
  /// 设置发送状态
  void setSendingStatus(bool sending) {
    _isSending.value = sending;
  }
  
  /// 清空历史记录
  void clearHistory() {
    _smsHistory.clear();
  }
}
