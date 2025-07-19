import 'package:get/get.dart';

import '../../../utils/logger.dart';
import '../../../services/api_client.dart';
import '../../../data/models/task_statistics.dart';

class StatisticsController extends GetxController {
  // 响应式变量
  final RxBool isLoading = false.obs;
  final Rx<TaskStatisticsResponse?> statistics =
      Rx<TaskStatisticsResponse?>(null);
  final RxString errorMessage = ''.obs;

  // 计算属性
  int get totalTasks => statistics.value?.totalTasks ?? 0;
  int get pendingTasks => statistics.value?.totalPendingTasks ?? 0;
  int get sendingTasks => statistics.value?.processingTasks ?? 0;
  int get successTasks => statistics.value?.successTasks ?? 0;
  int get failedTasks => statistics.value?.failedTasks ?? 0;
  double get successRate => statistics.value?.successRate ?? 0.0;

  @override
  void onInit() {
    super.onInit();
    refreshStatistics();
    AppLogger.info('StatisticsController initialized');
  }

  // 刷新统计数据
  Future<void> refreshStatistics() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      AppLogger.info('开始获取统计数据...');
      final result = await ApiClient.getStatistics();

      statistics.value = result;
      AppLogger.info('统计数据获取成功: 总任务数=${result.totalTasks}');
    } catch (e) {
      errorMessage.value = '获取统计数据失败：$e';
      AppLogger.error('获取统计数据失败', e);
    } finally {
      isLoading.value = false;
    }
  }

  // 获取状态分布数据（用于图表显示）
  List<Map<String, dynamic>> getStatusDistribution() {
    return [
      {'status': '待发送', 'count': pendingTasks, 'color': 0xFFFF9800},
      {'status': '发送中', 'count': sendingTasks, 'color': 0xFF2196F3},
      {'status': '成功', 'count': successTasks, 'color': 0xFF4CAF50},
      {'status': '失败', 'count': failedTasks, 'color': 0xFFF44336},
    ];
  }

  // 检查是否有数据
  bool get hasData => statistics.value != null;

  // 检查是否有错误
  bool get hasError => errorMessage.value.isNotEmpty;
}
