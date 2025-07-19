import 'package:json_annotation/json_annotation.dart';
import '../../utils/constants.dart';

part 'app_settings.g.dart';

@JsonSerializable()
class AppSettings {
  @JsonKey(name: 'server_url')
  final String serverUrl;
  
  @JsonKey(name: 'app_id')
  final String appId;
  
  final String username;
  final String password;
  
  @JsonKey(name: 'polling_interval')
  final int pollingInterval; // 轮询间隔(秒)
  
  @JsonKey(name: 'task_limit')
  final int taskLimit; // 一次获取任务数量
  
  @JsonKey(name: 'send_interval')
  final int sendInterval; // 发送间隔(毫秒)

  AppSettings({
    required this.serverUrl,
    required this.appId,
    required this.username,
    required this.password,
    this.pollingInterval = AppConstants.defaultPollingInterval,
    this.taskLimit = AppConstants.defaultTaskLimit,
    this.sendInterval = AppConstants.defaultSendInterval,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  // 创建默认设置
  factory AppSettings.defaultSettings() {
    return AppSettings(
      serverUrl: '',
      appId: '',
      username: '',
      password: '',
      pollingInterval: AppConstants.defaultPollingInterval,
      taskLimit: AppConstants.defaultTaskLimit,
      sendInterval: AppConstants.defaultSendInterval,
    );
  }

  // 复制并修改设置
  AppSettings copyWith({
    String? serverUrl,
    String? appId,
    String? username,
    String? password,
    int? pollingInterval,
    int? taskLimit,
    int? sendInterval,
  }) {
    return AppSettings(
      serverUrl: serverUrl ?? this.serverUrl,
      appId: appId ?? this.appId,
      username: username ?? this.username,
      password: password ?? this.password,
      pollingInterval: pollingInterval ?? this.pollingInterval,
      taskLimit: taskLimit ?? this.taskLimit,
      sendInterval: sendInterval ?? this.sendInterval,
    );
  }

  // 验证设置是否完整
  bool get isValid {
    return serverUrl.isNotEmpty &&
           appId.isNotEmpty &&
           username.isNotEmpty &&
           password.isNotEmpty &&
           pollingInterval > 0 &&
           taskLimit > 0 &&
           sendInterval > 0;
  }

  // 获取完整的API URL
  String getApiUrl(String endpoint) {
    String baseUrl = serverUrl;
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }
    return baseUrl + endpoint;
  }
}
