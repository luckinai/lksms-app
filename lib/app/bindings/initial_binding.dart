import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../services/notification_service.dart';
import '../services/foreground_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 存储提供者
    // Get.put<StorageProvider>(StorageProvider(), permanent: true);
    
    // API提供者
    // Get.put<ApiProvider>(ApiProvider(), permanent: true);
    
    // 数据仓库
    // Get.put<SettingsRepository>(SettingsRepository(), permanent: true);
    // Get.put<SmsRepository>(SmsRepository(), permanent: true);
    
    // 服务
    // Get.put<ApiClient>(ApiClient(), permanent: true);
    // Get.put<SmsService>(SmsService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<ForegroundService>(ForegroundService(), permanent: true);

    // 控制器
    Get.put<AppController>(AppController(), permanent: true);
    // Get.put<SmsServiceController>(SmsServiceController(), permanent: true);
    // Get.put<TasksController>(TasksController(), permanent: true);
    // Get.put<StatisticsController>(StatisticsController(), permanent: true);
  }
}
