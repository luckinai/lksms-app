import 'package:json_annotation/json_annotation.dart';

part 'sent_task.g.dart';

/// 已发送任务状态枚举
enum SentTaskStatus {
  @JsonValue('success')
  success,
  @JsonValue('failed')
  failed,
}

/// 已发送任务模型
@JsonSerializable()
class SentTask {
  /// 任务ID
  final int id;
  
  /// 手机号码
  final String phone;
  
  /// 短信内容
  final String content;
  
  /// 发送状态
  final SentTaskStatus status;
  
  /// 发送时间
  @JsonKey(name: 'sent_at')
  final DateTime sentAt;
  
  /// 失败原因（仅在失败时有值）
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  
  /// 应用ID
  @JsonKey(name: 'app_id')
  final String appId;

  const SentTask({
    required this.id,
    required this.phone,
    required this.content,
    required this.status,
    required this.sentAt,
    this.errorMessage,
    required this.appId,
  });

  factory SentTask.fromJson(Map<String, dynamic> json) =>
      _$SentTaskFromJson(json);

  Map<String, dynamic> toJson() => _$SentTaskToJson(this);

  /// 是否发送成功
  bool get isSuccess => status == SentTaskStatus.success;
  
  /// 是否发送失败
  bool get isFailed => status == SentTaskStatus.failed;
  
  /// 获取状态文本
  String get statusText {
    switch (status) {
      case SentTaskStatus.success:
        return '成功';
      case SentTaskStatus.failed:
        return '失败';
    }
  }
  
  /// 获取状态颜色（用于UI显示）
  String get statusColor {
    switch (status) {
      case SentTaskStatus.success:
        return 'green';
      case SentTaskStatus.failed:
        return 'red';
    }
  }
  
  /// 复制并修改任务
  SentTask copyWith({
    int? id,
    String? phone,
    String? content,
    SentTaskStatus? status,
    DateTime? sentAt,
    String? errorMessage,
    String? appId,
  }) {
    return SentTask(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      content: content ?? this.content,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      errorMessage: errorMessage ?? this.errorMessage,
      appId: appId ?? this.appId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentTask &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SentTask{id: $id, phone: $phone, status: $status, sentAt: $sentAt}';
  }
}

/// 已发送任务分页响应
@JsonSerializable()
class SentTaskPageResponse {
  /// 任务列表
  final List<SentTask> tasks;
  
  /// 总数量
  @JsonKey(name: 'total_count')
  final int totalCount;
  
  /// 当前页码
  @JsonKey(name: 'current_page')
  final int currentPage;
  
  /// 每页数量
  @JsonKey(name: 'page_size')
  final int pageSize;
  
  /// 总页数
  @JsonKey(name: 'total_pages')
  final int totalPages;
  
  /// 是否有下一页
  @JsonKey(name: 'has_next')
  final bool hasNext;
  
  /// 是否有上一页
  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  const SentTaskPageResponse({
    required this.tasks,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory SentTaskPageResponse.fromJson(Map<String, dynamic> json) =>
      _$SentTaskPageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SentTaskPageResponseToJson(this);

  /// 是否为空
  bool get isEmpty => tasks.isEmpty;
  
  /// 是否不为空
  bool get isNotEmpty => tasks.isNotEmpty;
  
  /// 成功任务数量
  int get successCount => tasks.where((task) => task.isSuccess).length;
  
  /// 失败任务数量
  int get failedCount => tasks.where((task) => task.isFailed).length;
  
  /// 成功率
  double get successRate {
    if (tasks.isEmpty) return 0.0;
    return (successCount / tasks.length) * 100;
  }

  @override
  String toString() {
    return 'SentTaskPageResponse{totalCount: $totalCount, currentPage: $currentPage, pageSize: $pageSize}';
  }
}
