import 'package:get/get.dart';

import '../controllers/layout_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../statistics/controllers/statistics_controller.dart';

class LayoutBinding extends Bindings {
  @override
  void dependencies() {
    // 注册布局控制器
    Get.lazyPut<LayoutController>(() => LayoutController());
    
    // 注册所有页面的控制器，这样它们在需要时会被创建
    Get.lazyPut<HomeController>(() => HomeController());
    // Get.lazyPut<TasksController>(() => TasksController());
    Get.lazyPut<StatisticsController>(() => StatisticsController());
  }
}
