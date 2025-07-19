// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportRequest _$ReportRequestFromJson(Map<String, dynamic> json) =>
    ReportRequest(
      taskId: json['task_id'] as String,
      appId: json['app_id'] as String,
      status: (json['status'] as num).toInt(),
      errorMessage: json['error_message'] as String?,
      shouldRetry: json['should_retry'] as bool? ?? false,
    );

Map<String, dynamic> _$ReportRequestToJson(ReportRequest instance) =>
    <String, dynamic>{
      'task_id': instance.taskId,
      'app_id': instance.appId,
      'status': instance.status,
      'error_message': instance.errorMessage,
      'should_retry': instance.shouldRetry,
    };
