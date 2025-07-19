import 'package:logger/logger.dart';

/// 应用日志工具类
/// 提供统一的日志记录功能
class AppLogger {
  static Logger? _logger;

  /// 初始化日志系统
  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // 显示调用栈的方法数量
        errorMethodCount: 8, // 错误时显示的调用栈方法数量
        lineLength: 120, // 每行的长度
        colors: true, // 启用颜色
        printEmojis: true, // 启用表情符号
        // 使用新的 API 替代过时的 printTime
        noBoxingByDefault: false,
      ),
    );
  }

  /// 确保logger已初始化
  static void _ensureInitialized() {
    if (_logger == null) {
      init();
    }
  }

  /// 调试日志
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger!.d(message, error: error, stackTrace: stackTrace);
  }

  /// 信息日志
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger!.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger!.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger!.e(message, error: error, stackTrace: stackTrace);
  }

  /// 致命错误日志
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger!.f(message, error: error, stackTrace: stackTrace);
  }

  /// 详细日志（仅在调试模式下显示）
  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger!.t(message, error: error, stackTrace: stackTrace);
  }
}
