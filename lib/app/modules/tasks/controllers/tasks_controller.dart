// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../data/models/pending_task.dart';
// import '../../../data/repositories/sms_repository.dart';
// import '../../../utils/logger.dart';

// class TasksController extends GetxController {
//   // late final SmsRepository _smsRepository;

//   // 响应式变量
//   final RxBool isLoading = false.obs;
//   final RxString searchKeyword = ''.obs;
//   final Rx<TaskStatus?> filterStatus = Rx<TaskStatus?>(null);
//   final RxList<LocalTask> tasks = <LocalTask>[].obs;
//   final RxList<LocalTask> filteredTasks = <LocalTask>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // _smsRepository = Get.find<SmsRepository>();
//     refreshTasks();
//     AppLogger.info('TasksController initialized');
//   }

//   // 刷新任务列表
//   Future<void> refreshTasks() async {
//     await loadTasks();
//   }

//   // 加载任务列表
//   Future<void> loadTasks() async {
//     if (isLoading.value) return;

//     isLoading.value = true;

//     try {
//       // 获取所有本地任务
//       final allTasks = await _smsRepository.getAllTasks();
//       tasks.assignAll(allTasks);

//       // 应用过滤条件
//       _applyFilters();

//       AppLogger.info('加载了 ${tasks.length} 个任务');
//     } catch (e) {
//       AppLogger.error('加载任务失败', e);
//       Get.snackbar(
//         '加载失败',
//         '无法加载任务列表: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // 搜索任务
//   void searchTasks(String keyword) {
//     searchKeyword.value = keyword;
//     _applyFilters();
//   }

//   // 按状态过滤
//   void filterByStatus(TaskStatus? status) {
//     filterStatus.value = status;
//     _applyFilters();
//   }

//   // 清除筛选条件
//   void clearFilters() {
//     searchKeyword.value = '';
//     filterStatus.value = null;
//     _applyFilters();
//   }

//   // 应用过滤条件
//   void _applyFilters() {
//     var filtered = List<LocalTask>.from(tasks);

//     // 按状态过滤
//     if (filterStatus.value != null) {
//       filtered = filtered.where((task) => task.status == filterStatus.value).toList();
//     }

//     // 按关键词搜索
//     if (searchKeyword.value.isNotEmpty) {
//       final keyword = searchKeyword.value.toLowerCase();
//       filtered = filtered.where((task) =>
//           task.phoneNumber.toLowerCase().contains(keyword) ||
//           task.content.toLowerCase().contains(keyword) ||
//           task.taskId.toLowerCase().contains(keyword)).toList();
//     }

//     // 按时间倒序排列（最新的在前）
//     filtered.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

//     filteredTasks.assignAll(filtered);
//   }

//   // 获取统计信息
//   Map<String, int> get taskStatistics {
//     final successCount = tasks.where((task) => task.status == TaskStatus.success).length;
//     final failedCount = tasks.where((task) => task.status == TaskStatus.failed).length;
//     final pendingCount = tasks.where((task) => task.status == TaskStatus.pending).length;
//     final sendingCount = tasks.where((task) => task.status == TaskStatus.sending).length;

//     return {
//       'total': tasks.length,
//       'success': successCount,
//       'failed': failedCount,
//       'pending': pendingCount,
//       'sending': sendingCount,
//     };
//   }

//   // 获取成功率
//   double get successRate {
//     if (tasks.isEmpty) return 0.0;
//     final successCount = tasks.where((task) => task.status == TaskStatus.success).length;
//     return (successCount / tasks.length) * 100;
//   }

//   // 获取过滤后的任务（用于兼容现有UI）
//   List<LocalTask> get allTasks => filteredTasks;

//   // 清除已完成的任务
//   Future<void> clearCompletedTasks() async {
//     try {
//       // 获取成功和失败的任务
//       final completedTasks = tasks.where((task) =>
//           task.status == TaskStatus.success || task.status == TaskStatus.failed).toList();

//       if (completedTasks.isEmpty) {
//         Get.snackbar(
//           '提示',
//           '没有已完成的任务需要清除',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//         return;
//       }

//       // 删除已完成的任务
//       for (final task in completedTasks) {
//         await _smsRepository.deleteTask(task.taskId);
//       }

//       // 刷新任务列表
//       await refreshTasks();

//       Get.snackbar(
//         '成功',
//         '已清除 ${completedTasks.length} 个已完成的任务',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       AppLogger.error('清除已完成任务失败', e);
//       Get.snackbar(
//         '失败',
//         '清除任务失败: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

// }
