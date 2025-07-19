// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sent_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SentTask _$SentTaskFromJson(Map<String, dynamic> json) => SentTask(
      id: (json['id'] as num).toInt(),
      phone: json['phone'] as String,
      content: json['content'] as String,
      status: $enumDecode(_$SentTaskStatusEnumMap, json['status']),
      sentAt: DateTime.parse(json['sent_at'] as String),
      errorMessage: json['error_message'] as String?,
      appId: json['app_id'] as String,
    );

Map<String, dynamic> _$SentTaskToJson(SentTask instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'content': instance.content,
      'status': _$SentTaskStatusEnumMap[instance.status]!,
      'sent_at': instance.sentAt.toIso8601String(),
      'error_message': instance.errorMessage,
      'app_id': instance.appId,
    };

const _$SentTaskStatusEnumMap = {
  SentTaskStatus.success: 'success',
  SentTaskStatus.failed: 'failed',
};

SentTaskPageResponse _$SentTaskPageResponseFromJson(
        Map<String, dynamic> json) =>
    SentTaskPageResponse(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => SentTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
      currentPage: (json['current_page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );

Map<String, dynamic> _$SentTaskPageResponseToJson(
        SentTaskPageResponse instance) =>
    <String, dynamic>{
      'tasks': instance.tasks,
      'total_count': instance.totalCount,
      'current_page': instance.currentPage,
      'page_size': instance.pageSize,
      'total_pages': instance.totalPages,
      'has_next': instance.hasNext,
      'has_prev': instance.hasPrev,
    };
