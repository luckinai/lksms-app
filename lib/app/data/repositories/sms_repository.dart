// import 'package:get/get.dart';

// import '../models/pending_task.dart';
// import '../../providers/storage_provider.dart';
// import '../../utils/constants.dart';
// import '../../utils/logger.dart';

// class SmsRepository {
//   // StorageProvider的方法都是静态的，不需要实例变量

//   // 获取所有本地任务
//   static Future<List<LocalTask>> getAllTasks() async {
//     try {
//       final data = StorageProvider.read<List<dynamic>>(
//         AppConstants.storageKeyTasks,
//       );

//       if (data != null) {
//         return data
//             .map((item) => LocalTask.fromJson(item as Map<String, dynamic>))
//             .toList();
//       }

//       return [];
//     } catch (e) {
//       AppLogger.error('Error getting all tasks', e);
//       return [];
//     }
//   }

//   // 保存任务列表
//   static Future<bool> saveTasks(List<LocalTask> tasks) async {
//     try {
//       final data = tasks.map((task) => task.toJson()).toList();
//       await StorageProvider.write(AppConstants.storageKeyTasks, data);
//       return true;
//     } catch (e) {
//       AppLogger.error('Error saving tasks', e);
//       return false;
//     }
//   }

//   // 添加新任务
//   static Future<bool> addTask(LocalTask task) async {
//     try {
//       final tasks = await getAllTasks();
//       tasks.add(task);
//       return await saveTasks(tasks);
//     } catch (e) {
//       AppLogger.error('Error adding task', e);
//       return false;
//     }
//   }

//   // 批量添加任务
//   Future<bool> addTasks(List<LocalTask> newTasks) async {
//     try {
//       final existingTasks = await getAllTasks();
//       existingTasks.addAll(newTasks);
//       return await saveTasks(existingTasks);
//     } catch (e) {
//       AppLogger.error('Error adding tasks', e);
//       return false;
//     }
//   }

//   // 更新任务状态
//   Future<bool> updateTaskStatus(
//     String taskId,
//     TaskStatus status, {
//     DateTime? sentAt,
//     String? errorMessage,
//   }) async {
//     try {
//       final tasks = await getAllTasks();
//       final index = tasks.indexWhere((task) => task.taskId == taskId);

//       if (index != -1) {
//         tasks[index] = tasks[index].copyWith(
//           status: status,
//           sentAt: sentAt,
//           errorMessage: errorMessage,
//         );
//         return await saveTasks(tasks);
//       }

//       return false;
//     } catch (e) {
//       AppLogger.error('Error updating task status', e);
//       return false;
//     }
//   }

//   // 获取特定状态的任务
//   Future<List<LocalTask>> getTasksByStatus(TaskStatus status) async {
//     try {
//       final tasks = await getAllTasks();
//       return tasks.where((task) => task.status == status).toList();
//     } catch (e) {
//       AppLogger.error('Error getting tasks by status', e);
//       return [];
//     }
//   }

//   // 获取待发送任务
//   Future<List<LocalTask>> getPendingTasks() async {
//     return await getTasksByStatus(TaskStatus.pending);
//   }

//   // 获取发送中任务
//   Future<List<LocalTask>> getSendingTasks() async {
//     return await getTasksByStatus(TaskStatus.sending);
//   }

//   // 获取成功任务
//   Future<List<LocalTask>> getSuccessTasks() async {
//     return await getTasksByStatus(TaskStatus.success);
//   }

//   // 获取失败任务
//   Future<List<LocalTask>> getFailedTasks() async {
//     return await getTasksByStatus(TaskStatus.failed);
//   }

//   // 删除任务
//   Future<bool> deleteTask(String taskId) async {
//     try {
//       final tasks = await getAllTasks();
//       tasks.removeWhere((task) => task.taskId == taskId);
//       return await saveTasks(tasks);
//     } catch (e) {
//       AppLogger.error('Error deleting task', e);
//       return false;
//     }
//   }

//   // 清空所有任务
//   Future<bool> clearAllTasks() async {
//     try {
//       await StorageProvider.remove(AppConstants.storageKeyTasks);
//       return true;
//     } catch (e) {
//       AppLogger.error('Error clearing all tasks', e);
//       return false;
//     }
//   }

//   // 清空特定状态的任务
//   Future<bool> clearTasksByStatus(TaskStatus status) async {
//     try {
//       final tasks = await getAllTasks();
//       final filteredTasks =
//           tasks.where((task) => task.status != status).toList();
//       return await saveTasks(filteredTasks);
//     } catch (e) {
//       AppLogger.error('Error clearing tasks by status', e);
//       return false;
//     }
//   }

//   // 获取任务统计
//   Future<Map<TaskStatus, int>> getTaskStatistics() async {
//     try {
//       final tasks = await getAllTasks();
//       final stats = <TaskStatus, int>{};

//       for (final status in TaskStatus.values) {
//         stats[status] = tasks.where((task) => task.status == status).length;
//       }

//       return stats;
//     } catch (e) {
//       AppLogger.error('Error getting task statistics', e);
//       return {};
//     }
//   }

//   // 获取任务总数
//   Future<int> getTotalTaskCount() async {
//     try {
//       final tasks = await getAllTasks();
//       return tasks.length;
//     } catch (e) {
//       AppLogger.error('Error getting total task count', e);
//       return 0;
//     }
//   }

//   // 检查任务是否存在
//   Future<bool> taskExists(String taskId) async {
//     try {
//       final tasks = await getAllTasks();
//       return tasks.any((task) => task.taskId == taskId);
//     } catch (e) {
//       AppLogger.error('Error checking task existence', e);
//       return false;
//     }
//   }

//   // 获取最近的任务
//   Future<List<LocalTask>> getRecentTasks({int limit = 10}) async {
//     try {
//       final tasks = await getAllTasks();
//       tasks.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
//       return tasks.take(limit).toList();
//     } catch (e) {
//       AppLogger.error('Error getting recent tasks', e);
//       return [];
//     }
//   }
// }
