import 'package:flutter/material.dart';

class AppConstants {
  // App 信息
  static const String appName = 'Flutter Template';
  static const String appVersion = '1.0.0';

  // 主题颜色
  static const Color primaryColor = Color.fromARGB(255, 160, 235, 8);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color.fromARGB(255, 63, 235, 69);
  static const Color warningColor = Color(0xFFFF9800);

  // 间距
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // 圆角
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // 动画时长
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // 网络配置
  static const String baseUrl = 'https://api.example.com';
  static const int connectTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒
  static const int sendTimeout = 30000; // 30秒

  // 存储键名
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyUserToken = 'user_token';
  static const String keyUserInfo = 'user_info';

  // 页面路由
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';
}
