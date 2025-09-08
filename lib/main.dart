import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/config/app_environment.dart';
import 'core/utils/logger.dart';
import 'shared/providers/app_providers.dart';
import 'features/auth/presentation/providers/auth_providers_config.dart';
import 'app.dart';

/// 主入口 - 默认开发环境
void main() => mainWithEnvironment();

/// 开发环境入口
void mainDevelopment() => mainWithEnvironment(AppEnvironment.development);

/// 灰度环境入口
void mainStaging() => mainWithEnvironment(AppEnvironment.staging);

/// 正式环境入口
void mainProduction() => mainWithEnvironment(AppEnvironment.production);

/// 带环境参数的主入口
Future<void> mainWithEnvironment([AppEnvironment? environment]) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化应用配置
  AppConfig.instance.initialize(environment: environment);

  // 初始化日志（根据环境配置）
  await AppLogger.init(enableLogging: AppConfig.instance.enableLogging);

  // 初始化 SharedPreferences - 新架构需要
  final prefs = await SharedPreferences.getInstance();

  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 设置错误处理
  FlutterError.onError = (details) {
    if (AppConfig.instance.enableLogging) {
      AppLogger.talker.handle(details.exception, details.stack);
    }
  };

  // 根据环境决定是否添加观察者
  final observers = <ProviderObserver>[];
  if (AppConfig.instance.enableLogging) {
    observers.add(TalkerRiverpodObserver(talker: AppLogger.talker));
  }

  // 设置依赖注入覆盖 - 为新架构提供 SharedPreferences 实例
  final overrides = <Override>[
    sharedPreferencesProvider.overrideWithValue(prefs),
  ];

  runApp(
    ProviderScope(
      observers: observers,
      overrides: overrides, // 添加依赖注入覆盖
      child: const MyApp(),
    ),
  );
}
