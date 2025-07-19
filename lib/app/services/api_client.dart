import 'package:dio/dio.dart';
import 'dart:convert';

import '../data/models/api_response.dart';
import '../data/models/pending_task.dart';
import '../data/models/report_request.dart';
import '../data/models/task_statistics.dart';
import '../providers/api_provider.dart';
import '../data/repositories/settings_repository.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class ApiClient {
  static bool _initialized = false;

  // 初始化 API 服务
  static void init() {
    if (!_initialized) {
      ApiProvider.init();
      _setupInterceptors();
      _initialized = true;
      AppLogger.info('ApiService initialized');
    }
  }

  static void _setupInterceptors() {
    ApiProvider.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加Basic认证
          final settings = await SettingsRepository.getSettings();
          if (settings != null &&
              settings.username.isNotEmpty &&
              settings.password.isNotEmpty) {
            final credentials = base64Encode(
                utf8.encode('${settings.username}:${settings.password}'));
            options.headers['Authorization'] = 'Basic $credentials';
          }

          // 设置Content-Type
          options.headers['Content-Type'] = 'application/json';

          handler.next(options);
        },
        onError: (error, handler) {
          // 统一错误处理
          AppLogger.error('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // 获取待发送任务
  static Future<PendingTasksResponse> getPendingTasks({
    required String appId,
    int limit = AppConstants.defaultTaskLimit,
  }) async {
    init(); // 确保已初始化

    final settings = await SettingsRepository.getSettings();
    if (settings == null) {
      throw Exception('Settings not configured');
    }

    final url = settings.getApiUrl(AppConstants.apiPendingTasks);
    final response = await ApiProvider.dio.get(
      url,
      queryParameters: {
        'app_id': appId,
        'limit': limit,
      },
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess) {
        return PendingTasksResponse.fromJson(apiResponse.data!);
      } else {
        throw Exception(
            '获取任务异常,CODE: ${apiResponse.code}, MSG: ${apiResponse.message}');
      }
    } else {
      throw Exception('获取任务异常,HTTP CODE:${response.statusCode}');
    }
  }

  // 汇报发送结果
  static Future<void> reportResult(ReportRequest request) async {
    init(); // 确保已初始化
    final settings = await SettingsRepository.getSettings();
    if (settings == null) {
      throw Exception('Settings not configured');
    }

    final url = settings.getApiUrl(AppConstants.apiReport);
    final response = await ApiProvider.dio.post(
      url,
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (!apiResponse.isSuccess) {
        throw Exception(
            '汇报发送结果异常,CODE: ${apiResponse.code}, MSG: ${apiResponse.message}');
      }
    } else {
      throw Exception('汇报发送结果异常,HTTP CODE:${response.statusCode}');
    }
  }

  // 获取统计信息
  static Future<TaskStatisticsResponse> getStatistics() async {
    init(); // 确保已初始化

    final settings = await SettingsRepository.getSettings();
    if (settings == null) {
      throw Exception('Settings not configured');
    }

    final url = settings.getApiUrl(AppConstants.apiStatistics);
    final response = await ApiProvider.dio.get(url);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess) {
        return TaskStatisticsResponse.fromJson(apiResponse.data!);
      } else {
        throw Exception(
            '获取统计信息异常,CODE: ${apiResponse.code}, MSG: ${apiResponse.message}');
      }
    } else {
      throw Exception('获取统计信息异常,HTTP CODE:${response.statusCode}');
    }
  }

  // 测试连接
  static Future<bool> testConnection() async {
    init(); // 确保已初始化
    try {
      final settings = await SettingsRepository.getSettings();
      if (settings == null) {
        return false;
      }

      final url = settings.getApiUrl('/health');
      final response = await ApiProvider.dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Connection test failed: $e');
      return false;
    }
  }
}
