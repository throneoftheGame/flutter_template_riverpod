import 'package:flutter/foundation.dart';
import 'app_environment.dart';
import 'environment_config.dart';

/// 应用配置管理器
class AppConfig {
  AppConfig._();

  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();

  EnvironmentConfig? _config;

  /// 初始化配置
  void initialize({AppEnvironment? environment}) {
    // 优先使用传入的环境参数
    // 其次使用编译时环境变量
    // 最后默认使用开发环境
    final env = environment ?? 
        _getEnvironmentFromString(const String.fromEnvironment('ENVIRONMENT')) ?? 
        AppEnvironment.development;
    
    _config = EnvironmentConfig.fromEnvironment(env);
    
    if (kDebugMode) {
      print('🚀 App initialized with environment: ${_config!.environment.displayName}');
      print('📊 Config: $_config');
    }
  }

  /// 当前配置
  EnvironmentConfig get config {
    if (_config == null) {
      throw StateError('AppConfig not initialized. Call AppConfig.instance.initialize() first.');
    }
    return _config!;
  }

  /// 当前环境
  AppEnvironment get environment => config.environment;

  /// 应用名称
  String get appName => config.appName;

  /// API 基础URL
  String get apiBaseUrl => config.apiBaseUrl;

  /// API 超时时间
  int get apiTimeout => config.apiTimeout;

  /// 是否启用日志
  bool get enableLogging => config.enableLogging;

  /// 是否启用崩溃统计
  bool get enableCrashlytics => config.enableCrashlytics;

  /// 是否启用数据统计
  bool get enableAnalytics => config.enableAnalytics;

  /// 是否显示性能叠加层
  bool get showPerformanceOverlay => config.showPerformanceOverlay;

  /// 是否显示调试横幅
  bool get debugShowCheckedModeBanner => config.debugShowCheckedModeBanner;

  /// 是否为开发环境
  bool get isDevelopment => environment.isDevelopment;

  /// 是否为灰度环境
  bool get isStaging => environment.isStaging;

  /// 是否为正式环境
  bool get isProduction => environment.isProduction;

  /// 是否为调试模式
  bool get isDebugMode => environment.isDebugMode;

  /// 从字符串解析环境
  AppEnvironment? _getEnvironmentFromString(String? envString) {
    if (envString == null || envString.isEmpty) return null;
    
    switch (envString.toLowerCase()) {
      case 'development':
      case 'dev':
        return AppEnvironment.development;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      default:
        return null;
    }
  }

  /// 重置配置（主要用于测试）
  @visibleForTesting
  void reset() {
    _config = null;
  }
}
