import 'app_environment.dart';

/// 环境配置类
class EnvironmentConfig {
  const EnvironmentConfig._({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.apiTimeout,
    required this.enableLogging,
    required this.enableCrashlytics,
    required this.enableAnalytics,
    required this.showPerformanceOverlay,
    required this.debugShowCheckedModeBanner,
  });

  /// 当前环境
  final AppEnvironment environment;

  /// 应用名称
  final String appName;

  /// API 基础URL
  final String apiBaseUrl;

  /// API 超时时间（毫秒）
  final int apiTimeout;

  /// 是否启用日志
  final bool enableLogging;

  /// 是否启用崩溃统计
  final bool enableCrashlytics;

  /// 是否启用数据统计
  final bool enableAnalytics;

  /// 是否显示性能叠加层
  final bool showPerformanceOverlay;

  /// 是否显示调试横幅
  final bool debugShowCheckedModeBanner;

  /// 开发环境配置
  static const development = EnvironmentConfig._(
    environment: AppEnvironment.development,
    appName: 'Flutter Template (Dev)',
    apiBaseUrl: 'https://dev-api.example.com',
    apiTimeout: 30000,
    enableLogging: true,
    enableCrashlytics: false,
    enableAnalytics: false,
    showPerformanceOverlay: false,
    debugShowCheckedModeBanner: true,
  );

  /// 灰度环境配置
  static const staging = EnvironmentConfig._(
    environment: AppEnvironment.staging,
    appName: 'Flutter Template (Staging)',
    apiBaseUrl: 'https://staging-api.example.com',
    apiTimeout: 30000,
    enableLogging: true,
    enableCrashlytics: true,
    enableAnalytics: false,
    showPerformanceOverlay: false,
    debugShowCheckedModeBanner: true,
  );

  /// 正式环境配置
  static const production = EnvironmentConfig._(
    environment: AppEnvironment.production,
    appName: 'Flutter Template',
    apiBaseUrl: 'https://api.example.com',
    apiTimeout: 15000,
    enableLogging: false,
    enableCrashlytics: true,
    enableAnalytics: true,
    showPerformanceOverlay: false,
    debugShowCheckedModeBanner: false,
  );

  /// 根据环境获取配置
  static EnvironmentConfig fromEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return development;
      case AppEnvironment.staging:
        return staging;
      case AppEnvironment.production:
        return production;
    }
  }

  @override
  String toString() {
    return 'EnvironmentConfig('
        'environment: ${environment.name}, '
        'appName: $appName, '
        'apiBaseUrl: $apiBaseUrl, '
        'enableLogging: $enableLogging'
        ')';
  }
}
