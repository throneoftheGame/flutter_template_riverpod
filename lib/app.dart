import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_router.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/widgets/environment_banner.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: AppConfig.instance.appName,
      debugShowCheckedModeBanner: AppConfig.instance.debugShowCheckedModeBanner,
      showPerformanceOverlay: AppConfig.instance.showPerformanceOverlay,

      // 主题配置
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeMode,

      // 国际化配置
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('zh', 'CN')],

      // 路由配置
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.login,

      // 使用 builder 来包装环境横幅
      builder: (context, child) {
        return EnvironmentBanner(
          // 增加顶部偏移，避免与自定义header冲突
          topOffset: 70,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    // 使用 fromSeed 生成基础颜色方案，然后覆盖 primary 颜色为精确的自定义颜色
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          // 覆盖 primary 颜色为精确的自定义颜色，确保显示效果与设计稿一致
          primary: AppConstants.primaryColor,
          // 调整相关颜色以保持视觉协调性
          onPrimary: Colors.white, // primary 颜色上的文字颜色
          // 调整 primary container 相关颜色，使其与自定义 primary 颜色协调
          primaryContainer: AppConstants.primaryColor.withOpacity(
            0.12,
          ), // 浅色主题下的容器背景
          onPrimaryContainer: AppConstants.primaryColor, // 容器上的文字颜色
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      // 设置页面背景色 - 你可以选择以下几种方式：
      scaffoldBackgroundColor: colorScheme.surface, // 使用系统默认的surface颜色
      // scaffoldBackgroundColor: Colors.grey[50], // 使用浅灰色背景
      // scaffoldBackgroundColor: const Color(0xFFF5F5F5), // 使用自定义的浅灰色
      // scaffoldBackgroundColor: Colors.white, // 使用纯白色背景
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    // 使用 fromSeed 生成基础颜色方案，然后覆盖 primary 颜色为精确的自定义颜色
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.dark,
        ).copyWith(
          // 覆盖 primary 颜色为精确的自定义颜色，确保显示效果与设计稿一致
          primary: AppConstants.primaryColor,
          // 调整相关颜色以保持视觉协调性
          onPrimary: Colors.black, // 暗色主题下，primary 颜色上使用黑色文字以确保对比度
          // 调整 primary container 相关颜色，使其与自定义 primary 颜色协调
          primaryContainer: AppConstants.primaryColor.withOpacity(
            0.24,
          ), // 暗色主题下的容器背景，透明度更高
          onPrimaryContainer: AppConstants.primaryColor.withOpacity(
            0.87,
          ), // 容器上的文字颜色，略透明
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      // 设置暗色主题的页面背景色
      scaffoldBackgroundColor: colorScheme.surface, // 使用系统默认的surface颜色
      // scaffoldBackgroundColor: Colors.grey[900], // 使用深灰色背景
      // scaffoldBackgroundColor: const Color(0xFF121212), // 使用自定义的深色背景
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
