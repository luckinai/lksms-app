class AppConstants {
  // 存储键名
  static const String storageKeySettings = 'app_settings';
  static const String storageKeyTasks = 'pending_tasks';
  
  // 默认配置
  static const int defaultPollingInterval = 30; // 30秒
  static const int defaultTaskLimit = 10;
  static const int defaultSendInterval = 1000; // 1秒
  
  // API路径
  static const String apiPendingTasks = '/api/v1/sms/tasks/pending';
  static const String apiReport = '/api/v1/sms/report';
  static const String apiStatistics = '/api/v1/admin/task-statistics';
  
  // 任务状态
  static const int taskStatusPending = 0;
  static const int taskStatusSending = 1;
  static const int taskStatusSuccess = 2;
  static const int taskStatusFailed = 3;
  
  // 发送结果状态
  static const int reportStatusSuccess = 2;
  static const int reportStatusFailed = 3;
  
  // 前台服务
  static const int foregroundServiceId = 1000;
  static const String foregroundChannelId = 'lksms_foreground';
  static const String foregroundChannelName = 'LKSMS前台服务';
  
  // 通知
  static const String notificationChannelId = 'lksms_notification';
  static const String notificationChannelName = 'LKSMS通知';
}
