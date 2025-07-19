import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class ControlPanelWidget extends GetView<HomeController> {
  const ControlPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Icons.control_camera,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '服务控制',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 服务状态显示
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(controller.getServiceStatusColor())
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(controller.getServiceStatusColor())
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(controller.getServiceStatusColor()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.getServiceStatusText(),
                        style: TextStyle(
                          color: Color(controller.getServiceStatusColor()),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // 详细状态信息
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      '网络',
                      controller.isNetworkConnected ? '正常' : '断开',
                      controller.isNetworkConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),

            // 主要控制按钮
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return ElevatedButton.icon(
                      onPressed: controller.isLoading
                          ? null
                          : controller.toggleService,
                      icon: Icon(
                        controller.isServiceRunning
                            ? Icons.stop
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        controller.isServiceRunning ? '停止服务' : '启动服务',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isServiceRunning
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // // 权限设置按钮
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton.icon(
            //         onPressed:  controller.test,
            //         icon: const Icon(Icons.security),
            //         label: const Text('测试'),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
