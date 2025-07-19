import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/logger.dart';
import 'app/providers/sms_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化日志系统
  AppLogger.init();
  // 初始化本地存储
  await GetStorage.init();
  // 初始化原生短信服务
  SmsProvider.initialize();

  AppLogger.info('应用启动');
  
  runApp(
    GetMaterialApp(
      title: 'LKSMS',
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
