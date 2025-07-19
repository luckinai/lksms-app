import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/statistics_controller.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计信息'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshStatistics,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在加载统计数据...'),
              ],
            ),
          );
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refreshStatistics,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (!controller.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无数据',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '请检查服务器配置或稍后重试',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refreshStatistics,
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshStatistics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总览卡片
                _buildOverviewCard(context),
                const SizedBox(height: 16),

                // 状态分布卡片
                _buildStatusDistributionCard(context),
                const SizedBox(height: 16),

                // 详细统计卡片
                _buildDetailedStatsCard(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '总览',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 总任务数和成功率
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildStatCard(
                    '总任务数',
                    controller.totalTasks.toString(),
                    Colors.blue,
                    Icons.list_alt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '成功率',
                    '${controller.successRate.toStringAsFixed(1)}%',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 状态统计
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  '待发送',
                  controller.pendingTasks.toString(),
                  Colors.orange,
                  Icons.schedule,
                  small: true,
                ),
                _buildStatCard(
                  '发送中',
                  controller.sendingTasks.toString(),
                  Colors.blue,
                  Icons.send,
                  small: true,
                ),
                _buildStatCard(
                  '成功',
                  controller.successTasks.toString(),
                  Colors.green,
                  Icons.check_circle,
                  small: true,
                ),
                _buildStatCard(
                  '失败',
                  controller.failedTasks.toString(),
                  Colors.red,
                  Icons.error,
                  small: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistributionCard(BuildContext context) {
    final distribution = controller.getStatusDistribution();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '状态分布',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 状态分布列表
            ...distribution.map((item) => _buildStatusItem(
              item['status'] as String,
              item['count'] as int,
              Color(item['color'] as int),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatsCard(BuildContext context) {
    final stats = controller.statistics.value!;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '详细统计',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 详细数据行
            _buildDetailRow('新任务', stats.pendingNewTasks, Icons.fiber_new),
            _buildDetailRow('重试任务', stats.pendingRetryTasks, Icons.refresh),
            _buildDetailRow('处理中', stats.processingTasks, Icons.hourglass_empty),
            _buildDetailRow('成功完成', stats.successTasks, Icons.check_circle_outline),
            _buildDetailRow('失败任务', stats.failedTasks, Icons.error_outline),

            const Divider(height: 24),

            // 汇总信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '总计',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats.totalTasks} 个任务',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildTimeDistributionCard(BuildContext context) {
  //   final distribution = controller.getTimeDistribution();

  //   return Card(
  //     elevation: 4,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(
  //                 Icons.date_range,
  //                 color: Theme.of(context).primaryColor,
  //               ),
  //               const SizedBox(width: 8),
  //               Text(
  //                 '时间分布',
  //                 style: Theme.of(context).textTheme.titleLarge,
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),

  //           // 时间分布图表
  //           SizedBox(
  //             height: 200,
  //             child: _buildTimeChart(distribution),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatCard(String label, String value, Color color, IconData icon, {bool small = false}) {
    return Container(
      width: small ? 70 : double.infinity, // 使用double.infinity让容器自适应宽度
      padding: EdgeInsets.all(small ? 8 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: small ? 20 : 24),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: small ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: small ? 10 : 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget _buildStatusChart(List<Map<String, dynamic>> data) {
  //   // 简单的水平条形图
  //   return Column(
  //     children: data.map((item) {
  //       final count = item['count'] as int;
  //       final total = controller.totalTasks.value;
  //       final percentage = total > 0 ? count / total : 0.0;
  //       final color = Color(item['color'] as int);

  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 8.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   width: 12,
  //                   height: 12,
  //                   decoration: BoxDecoration(
  //                     color: color,
  //                     shape: BoxShape.circle,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Text(
  //                   '${item['status']} (${(percentage * 100).toStringAsFixed(1)}%)',
  //                   style: const TextStyle(fontSize: 12),
  //                 ),
  //                 const Spacer(),
  //                 Text(
  //                   count.toString(),
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     color: color,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 4),
  //             LinearProgressIndicator(
  //               value: percentage,
  //               backgroundColor: Colors.grey.withOpacity(0.2),
  //               valueColor: AlwaysStoppedAnimation<Color>(color),
  //               minHeight: 8,
  //               borderRadius: BorderRadius.circular(4),
  //             ),
  //           ],
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  // Widget _buildTimeChart(List<Map<String, dynamic>> data) {
  //   // 简单的垂直条形图
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: data.map((item) {
  //       final count = item['count'] as int;
  //       final maxCount = data.fold<int>(0, (max, item) =>
  //           (item['count'] as int) > max ? (item['count'] as int) : max);
  //       final height = maxCount > 0 ? (count / maxCount) * 150 : 0.0;

  //       return Column(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           Text(
  //             count.toString(),
  //             style: const TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 12,
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           Container(
  //             width: 60,
  //             height: height,
  //             decoration: BoxDecoration(
  //               color: Colors.blue.withOpacity(0.7),
  //               borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             item['period'] as String,
  //             style: const TextStyle(fontSize: 12),
  //           ),
  //         ],
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _buildStatusItem(String status, int count, Color color) {
    final total = controller.totalTasks;
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
