import 'package:json_annotation/json_annotation.dart';

part 'task_statistics.g.dart';

@JsonSerializable()
class TaskStatisticsResponse {
  @JsonKey(name: 'pending_new_tasks')
  final int pendingNewTasks;

  @JsonKey(name: 'pending_retry_tasks')
  final int pendingRetryTasks;

  @JsonKey(name: 'processing_tasks')
  final int processingTasks;

  @JsonKey(name: 'failed_tasks')
  final int failedTasks;

  @JsonKey(name: 'success_tasks')
  final int successTasks;

  TaskStatisticsResponse({
    required this.pendingNewTasks,
    required this.pendingRetryTasks,
    required this.processingTasks,
    required this.failedTasks,
    required this.successTasks,
  });

  factory TaskStatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskStatisticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TaskStatisticsResponseToJson(this);

  // 计算总的待处理任务数量
  int get totalPendingTasks => pendingNewTasks + pendingRetryTasks;

  // 计算总任务数量
  int get totalTasks => pendingNewTasks + pendingRetryTasks + processingTasks + failedTasks + successTasks;

  // 计算已完成任务数量（成功+失败）
  int get completedTasks => successTasks + failedTasks;

  // 计算成功率
  double get successRate {
    if (completedTasks == 0) return 0.0;
    return (successTasks / completedTasks) * 100;
  }
}
