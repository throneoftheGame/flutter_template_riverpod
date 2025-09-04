import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/utils/logger.dart';
import 'shared/providers/app_providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志
  await AppLogger.init();

  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 设置错误处理
  FlutterError.onError = (details) {
    AppLogger.talker.handle(details.exception, details.stack);
  };

  runApp(
    ProviderScope(
      observers: [TalkerRiverpodObserver(talker: AppLogger.talker)],
      child: const MyApp(),
    ),
  );
}
