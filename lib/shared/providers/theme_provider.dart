import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/constants/app_constants.dart';

/// 主题模式状态管理
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// 加载保存的主题模式
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(AppConstants.keyThemeMode);

    if (themeModeString != null) {
      switch (themeModeString) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        case 'system':
        default:
          state = ThemeMode.system;
          break;
      }
    }
  }

  /// 切换主题模式
  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;

    final prefs = await SharedPreferences.getInstance();
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }
    await prefs.setString(AppConstants.keyThemeMode, themeModeString);
  }

  /// 切换到下一个主题模式
  Future<void> toggleThemeMode() async {
    switch (state) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }
}

/// 主题模式 Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// 当前是否为暗色主题 Provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  switch (themeMode) {
    case ThemeMode.dark:
      return true;
    case ThemeMode.light:
      return false;
    case ThemeMode.system:
      // 这里可以根据系统主题判断，简化处理返回 false
      return false;
  }
});

/// 主题模式显示文本 Provider - 需要 BuildContext
final themeModeTextProvider = Provider.family<String, BuildContext>((
  ref,
  context,
) {
  final themeMode = ref.watch(themeModeProvider);
  final l10n = AppLocalizations.of(context)!;

  switch (themeMode) {
    case ThemeMode.light:
      return l10n.lightMode;
    case ThemeMode.dark:
      return l10n.darkMode;
    case ThemeMode.system:
      return l10n.systemMode;
  }
});
