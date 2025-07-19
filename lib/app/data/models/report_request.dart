import 'package:json_annotation/json_annotation.dart';

part 'report_request.g.dart';

@JsonSerializable()
class ReportRequest {
  @JsonKey(name: 'task_id')
  final String taskId;
  
  @JsonKey(name: 'app_id')
  final String appId;
  
  final int status;
  
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  
  @JsonKey(name: 'should_retry')
  final bool shouldRetry;

  ReportRequest({
    required this.taskId,
    required this.appId,
    required this.status,
    this.errorMessage,
    this.shouldRetry = false,
  });

  factory ReportRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReportRequestToJson(this);

  // 创建成功汇报
  factory ReportRequest.success({
    required String taskId,
    required String appId,
  }) {
    return ReportRequest(
      taskId: taskId,
      appId: appId,
      status: 2, // SUCCESS
      shouldRetry: false,
    );
  }

  // 创建失败汇报
  factory ReportRequest.failed({
    required String taskId,
    required String appId,
    required String errorMessage,
    bool shouldRetry = false,
  }) {
    return ReportRequest(
      taskId: taskId,
      appId: appId,
      status: 3, // FAILED
      errorMessage: errorMessage,
      shouldRetry: shouldRetry,
    );
  }
}
