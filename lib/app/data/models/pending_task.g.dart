// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingTaskResponse _$PendingTaskResponseFromJson(Map<String, dynamic> json) =>
    PendingTaskResponse(
      taskId: json['task_id'] as String,
      phoneNumber: json['phone_number'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$PendingTaskResponseToJson(
        PendingTaskResponse instance) =>
    <String, dynamic>{
      'task_id': instance.taskId,
      'phone_number': instance.phoneNumber,
      'content': instance.content,
    };

PendingTasksResponse _$PendingTasksResponseFromJson(
        Map<String, dynamic> json) =>
    PendingTasksResponse(
      totalCount: (json['total_count'] as num).toInt(),
      appId: json['app_id'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => PendingTaskResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PendingTasksResponseToJson(
        PendingTasksResponse instance) =>
    <String, dynamic>{
      'total_count': instance.totalCount,
      'app_id': instance.appId,
      'tasks': instance.tasks,
    };

LocalTask _$LocalTaskFromJson(Map<String, dynamic> json) => LocalTask(
      taskId: json['task_id'] as String,
      phoneNumber: json['phone_number'] as String,
      content: json['content'] as String,
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      receivedAt: DateTime.parse(json['received_at'] as String),
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$LocalTaskToJson(LocalTask instance) => <String, dynamic>{
      'task_id': instance.taskId,
      'phone_number': instance.phoneNumber,
      'content': instance.content,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'received_at': instance.receivedAt.toIso8601String(),
      'sent_at': instance.sentAt?.toIso8601String(),
      'error_message': instance.errorMessage,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.sending: 'sending',
  TaskStatus.success: 'success',
  TaskStatus.failed: 'failed',
};
