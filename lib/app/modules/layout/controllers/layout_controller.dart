import 'package:get/get.dart';
import '../../../utils/logger.dart';

class LayoutController extends GetxController {
  // 当前选中的底部导航索引
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('LayoutController initialized');
  }

  // 切换页面
  void changePage(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      AppLogger.debug('切换到页面: $index');
    }
  }

  // 获取当前页面名称
  String getCurrentPageName() {
    switch (currentIndex.value) {
      case 0:
        return '主页';
      case 1:
        return '任务';
      case 2:
        return '统计';
      default:
        return '主页';
    }
  }
}
