// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskStatisticsResponse _$TaskStatisticsResponseFromJson(
        Map<String, dynamic> json) =>
    TaskStatisticsResponse(
      pendingNewTasks: (json['pending_new_tasks'] as num).toInt(),
      pendingRetryTasks: (json['pending_retry_tasks'] as num).toInt(),
      processingTasks: (json['processing_tasks'] as num).toInt(),
      failedTasks: (json['failed_tasks'] as num).toInt(),
      successTasks: (json['success_tasks'] as num).toInt(),
    );

Map<String, dynamic> _$TaskStatisticsResponseToJson(
        TaskStatisticsResponse instance) =>
    <String, dynamic>{
      'pending_new_tasks': instance.pendingNewTasks,
      'pending_retry_tasks': instance.pendingRetryTasks,
      'processing_tasks': instance.processingTasks,
      'failed_tasks': instance.failedTasks,
      'success_tasks': instance.successTasks,
    };
