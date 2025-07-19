// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controllers/tasks_controller.dart';
// import '../../../data/models/pending_task.dart';

// class TasksView extends GetView<TasksController> {
//   const TasksView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('任务列表'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: _showFilterDialog,
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_sweep),
//             onPressed: _showClearTasksDialog,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//         // 搜索栏
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: TextField(
//             decoration: const InputDecoration(
//               hintText: '搜索任务...',
//               prefixIcon: Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//               ),
//             ),
//             onChanged: controller.searchTasks,
//           ),
//         ),
        
//         // 状态筛选
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Obx(() {
//             final stats = controller.taskStatistics;
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatChip('总计', stats['total'] ?? 0, Colors.blue),
//                 _buildStatChip('成功', stats['success'] ?? 0, Colors.green),
//                 _buildStatChip('失败', stats['failed'] ?? 0, Colors.red),
//               ],
//             );
//           }),
//         ),
        
//         const SizedBox(height: 16),
        
//         // 任务列表
//         Expanded(
//           child: Obx(() {
//             final tasks = controller.filteredTasks;
            
//             if (controller.isLoading.value) {
//               return const Center(child: CircularProgressIndicator());
//             }
            
//             if (tasks.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.inbox_outlined,
//                       size: 64,
//                       color: Colors.grey,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       '暂无任务记录',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
            
//             return RefreshIndicator(
//               onRefresh: controller.refreshTasks,
//               child: ListView.separated(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: tasks.length,
//                 separatorBuilder: (context, index) => const Divider(height: 1),
//                 itemBuilder: (context, index) {
//                   final task = tasks[index];
//                   return _buildTaskItem(task, context);
//                 },
//               ),
//             );
//           }),
//         ),
//       ],
//       ),
//     );
//   }

//   Widget _buildStatChip(String label, int count, Color color) {
//     return Chip(
//       label: Text(
//         '$label ($count)',
//         style: TextStyle(
//           color: color,
//           fontWeight: FontWeight.w500,
//           fontSize: 12,
//         ),
//       ),
//       backgroundColor: color.withOpacity(0.1),
//       side: BorderSide(color: color.withOpacity(0.3)),
//     );
//   }

//   Widget _buildTaskItem(LocalTask task, BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: CircleAvatar(
//           backgroundColor: _getStatusColor(task.status),
//           child: Icon(
//             _getStatusIcon(task.status),
//             color: Colors.white,
//             size: 20,
//           ),
//         ),
//         title: Text(
//           task.phoneNumber,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               task.content,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Text(
//                   _getStatusText(task.status),
//                   style: TextStyle(
//                     color: _getStatusColor(task.status),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _formatDateTime(task.sentAt ?? task.receivedAt),
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             if (task.status == TaskStatus.failed && task.errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   '错误: ${task.errorMessage}',
//                   style: const TextStyle(
//                     color: Colors.red,
//                     fontSize: 12,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//           ],
//         ),
//         onTap: () => _showTaskDetails(task, context),
//       ),
//     );
//   }

//   void _showTaskDetails(LocalTask task, BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: _getStatusColor(task.status),
//                   child: Icon(
//                     _getStatusIcon(task.status),
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         task.phoneNumber,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         _getStatusText(task.status),
//                         style: TextStyle(
//                           color: _getStatusColor(task.status),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               '短信内容:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(task.content),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Icon(Icons.access_time, size: 16, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${task.sentAt != null ? "发送时间" : "接收时间"}: ${_formatDateTime(task.sentAt ?? task.receivedAt)}',
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//             if (task.status == TaskStatus.failed && task.errorMessage != null) ...[
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.error, size: 16, color: Colors.red),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       '失败原因: ${task.errorMessage}',
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // 辅助方法
//   Color _getStatusColor(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.pending:
//         return Colors.orange;
//       case TaskStatus.sending:
//         return Colors.blue;
//       case TaskStatus.success:
//         return Colors.green;
//       case TaskStatus.failed:
//         return Colors.red;
//     }
//   }

//   IconData _getStatusIcon(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.pending:
//         return Icons.schedule;
//       case TaskStatus.sending:
//         return Icons.send;
//       case TaskStatus.success:
//         return Icons.check;
//       case TaskStatus.failed:
//         return Icons.close;
//     }
//   }

//   String _getStatusText(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.pending:
//         return '待发送';
//       case TaskStatus.sending:
//         return '发送中';
//       case TaskStatus.success:
//         return '成功';
//       case TaskStatus.failed:
//         return '失败';
//     }
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }

//   // 显示筛选对话框
//   void _showFilterDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('筛选任务'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               title: const Text('全部'),
//               leading: Radio<TaskStatus?>(
//                 value: null,
//                 groupValue: controller.filterStatus.value,
//                 onChanged: (value) {
//                   controller.filterByStatus(value);
//                   Get.back();
//                 },
//               ),
//             ),
//             ...TaskStatus.values.map((status) =>
//               ListTile(
//                 title: Text(_getStatusText(status)),
//                 leading: Radio<TaskStatus?>(
//                   value: status,
//                   groupValue: controller.filterStatus.value,
//                   onChanged: (value) {
//                     controller.filterByStatus(value);
//                     Get.back();
//                   },
//                 ),
//               )
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               controller.clearFilters();
//               Get.back();
//             },
//             child: const Text('清除筛选'),
//           ),
//         ],
//       ),
//     );
//   }

//   // 显示清除任务确认对话框
//   void _showClearTasksDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('确认清除'),
//         content: const Text('确定要清除所有已完成的任务吗？此操作不可撤销。'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Get.back();
//               await controller.clearCompletedTasks();
//             },
//             child: const Text('确认清除'),
//           ),
//         ],
//       ),
//     );
//   }
// }
