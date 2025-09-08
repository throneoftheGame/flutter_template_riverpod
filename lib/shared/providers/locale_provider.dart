import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/constants/app_constants.dart';

/// 语言状态管理
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en', 'US')) {
    _loadLocale();
  }

  /// 加载保存的语言设置
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString(AppConstants.keyLocale);

    if (localeString != null) {
      final parts = localeString.split('_');
      if (parts.length == 2) {
        state = Locale(parts[0], parts[1]);
      }
    }
  }

  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    state = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyLocale,
      '${locale.languageCode}_${locale.countryCode}',
    );
  }

  /// 切换语言（中英文）
  Future<void> toggleLocale() async {
    if (state.languageCode == 'en') {
      await setLocale(const Locale('zh', 'CN'));
    } else {
      await setLocale(const Locale('en', 'US'));
    }
  }
}

/// 语言 Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

/// 当前语言显示文本 Provider - 需要 BuildContext
final localeTextProvider = Provider.family<String, BuildContext>((
  ref,
  context,
) {
  final locale = ref.watch(localeProvider);
  final l10n = AppLocalizations.of(context)!;

  switch (locale.languageCode) {
    case 'zh':
      return l10n.chinese;
    case 'en':
    default:
      return l10n.english;
  }
});

/// 是否为中文 Provider
final isChineseProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'zh';
});
