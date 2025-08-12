import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/layout_controller.dart';
import '../../home/views/home_view.dart';
import '../../statistics/views/statistics_view.dart';

class LayoutView extends GetView<LayoutController> {
  const LayoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            // TasksView(),
            StatisticsView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '主页',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.list),
            //   label: '任务',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: '统计',
            ),
          ],
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
        ),
      );
    });
  }
}
