import 'package:json_annotation/json_annotation.dart';

part 'pending_task.g.dart';

@JsonSerializable()
class PendingTaskResponse {
  @JsonKey(name: 'task_id')
  final String taskId;
  
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  
  final String content;

  PendingTaskResponse({
    required this.taskId,
    required this.phoneNumber,
    required this.content,
  });

  factory PendingTaskResponse.fromJson(Map<String, dynamic> json) =>
      _$PendingTaskResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PendingTaskResponseToJson(this);
}

@JsonSerializable()
class PendingTasksResponse {
  @JsonKey(name: 'total_count')
  final int totalCount;
  
  @JsonKey(name: 'app_id')
  final String appId;
  
  final List<PendingTaskResponse> tasks;

  PendingTasksResponse({
    required this.totalCount,
    required this.appId,
    required this.tasks,
  });

  factory PendingTasksResponse.fromJson(Map<String, dynamic> json) =>
      _$PendingTasksResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PendingTasksResponseToJson(this);
}

// 本地任务状态枚举
enum TaskStatus {
  pending,   // 待发送
  sending,   // 发送中
  success,   // 发送成功
  failed,    // 发送失败
}

// 本地任务模型
@JsonSerializable()
class LocalTask {
  @JsonKey(name: 'task_id')
  final String taskId;
  
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  
  final String content;
  
  final TaskStatus status;
  
  @JsonKey(name: 'received_at')
  final DateTime receivedAt;
  
  @JsonKey(name: 'sent_at')
  final DateTime? sentAt;
  
  @JsonKey(name: 'error_message')
  final String? errorMessage;

  LocalTask({
    required this.taskId,
    required this.phoneNumber,
    required this.content,
    required this.status,
    required this.receivedAt,
    this.sentAt,
    this.errorMessage,
  });

  factory LocalTask.fromPendingTask(PendingTaskResponse task) {
    return LocalTask(
      taskId: task.taskId,
      phoneNumber: task.phoneNumber,
      content: task.content,
      status: TaskStatus.pending,
      receivedAt: DateTime.now(),
    );
  }

  LocalTask copyWith({
    String? taskId,
    String? phoneNumber,
    String? content,
    TaskStatus? status,
    DateTime? receivedAt,
    DateTime? sentAt,
    String? errorMessage,
  }) {
    return LocalTask(
      taskId: taskId ?? this.taskId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      content: content ?? this.content,
      status: status ?? this.status,
      receivedAt: receivedAt ?? this.receivedAt,
      sentAt: sentAt ?? this.sentAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory LocalTask.fromJson(Map<String, dynamic> json) =>
      _$LocalTaskFromJson(json);

  Map<String, dynamic> toJson() => _$LocalTaskToJson(this);
}
