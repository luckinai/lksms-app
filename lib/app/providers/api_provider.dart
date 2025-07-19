import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class ApiProvider {
  static Dio? _dio;

  // 初始化 Dio
  static void init() {
    if (_dio == null) {
      _initializeDio();
      AppLogger.info('ApiProvider initialized');
    }
  }

  // 获取 Dio 实例
  static Dio get dio {
    if (_dio == null) {
      init();
    }
    return _dio!;
  }

  static void _initializeDio() {
    _dio = Dio();

    // 设置基础配置
    _dio!.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加日志拦截器（仅在调试模式下）
    if (kDebugMode) {
      _dio!.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }

    // 添加错误处理拦截器
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _handleDioError(error);
          handler.next(error);
        },
      ),
    );
  }

  static void _handleDioError(DioException error) {
    String errorMessage = '';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = '连接超时';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = '发送超时';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = '接收超时';
        break;
      case DioExceptionType.badResponse:
        errorMessage = '服务器错误: ${error.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorMessage = '请求已取消';
        break;
      case DioExceptionType.unknown:
        errorMessage = '网络错误: ${error.message}';
        break;
      default:
        errorMessage = '未知错误';
    }

    AppLogger.error('API Error: $errorMessage');
  }

  // 设置基础URL
  static void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  // 添加认证头
  static void setAuthHeader(String username, String password) {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    dio.options.headers['Authorization'] = 'Basic $credentials';
  }

  // 清除认证头
  static void clearAuthHeader() {
    dio.options.headers.remove('Authorization');
  }

  // 添加自定义头
  static void addHeader(String key, String value) {
    dio.options.headers[key] = value;
  }

  // 移除自定义头
  static void removeHeader(String key) {
    dio.options.headers.remove(key);
  }
}
