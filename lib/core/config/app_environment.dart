/// 应用环境枚举
enum AppEnvironment {
  /// 开发环境
  development,
  /// 灰度环境
  staging,
  /// 正式环境
  production,
}

/// 环境配置扩展
extension AppEnvironmentExtension on AppEnvironment {
  /// 环境名称
  String get name {
    switch (this) {
      case AppEnvironment.development:
        return 'development';
      case AppEnvironment.staging:
        return 'staging';
      case AppEnvironment.production:
        return 'production';
    }
  }

  /// 环境显示名称
  String get displayName {
    switch (this) {
      case AppEnvironment.development:
        return '开发环境';
      case AppEnvironment.staging:
        return '灰度环境';
      case AppEnvironment.production:
        return '正式环境';
    }
  }

  /// 是否为开发环境
  bool get isDevelopment => this == AppEnvironment.development;

  /// 是否为灰度环境
  bool get isStaging => this == AppEnvironment.staging;

  /// 是否为正式环境
  bool get isProduction => this == AppEnvironment.production;

  /// 是否为调试模式（开发和灰度环境）
  bool get isDebugMode => isDevelopment || isStaging;
}
