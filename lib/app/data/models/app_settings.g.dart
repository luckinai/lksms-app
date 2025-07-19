// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      serverUrl: json['server_url'] as String,
      appId: json['app_id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      pollingInterval: (json['polling_interval'] as num?)?.toInt() ??
          AppConstants.defaultPollingInterval,
      taskLimit: (json['task_limit'] as num?)?.toInt() ??
          AppConstants.defaultTaskLimit,
      sendInterval: (json['send_interval'] as num?)?.toInt() ??
          AppConstants.defaultSendInterval,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'server_url': instance.serverUrl,
      'app_id': instance.appId,
      'username': instance.username,
      'password': instance.password,
      'polling_interval': instance.pollingInterval,
      'task_limit': instance.taskLimit,
      'send_interval': instance.sendInterval,
    };
