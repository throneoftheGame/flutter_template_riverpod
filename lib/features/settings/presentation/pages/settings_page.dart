import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/locale_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeModeText = ref.watch(themeModeTextProvider);
    final locale = ref.watch(localeProvider);
    final localeText = ref.watch(localeTextProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        children: [
          // 外观设置
          _buildSectionHeader(context, '外观设置'),
          _buildThemeModeTile(context, ref, themeMode, themeModeText),
          _buildLanguageTile(context, ref, locale, localeText),

          const Divider(),

          // 账户设置
          _buildSectionHeader(context, '账户设置'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: '个人资料',
            subtitle: '管理您的个人信息',
            onTap: () => context.showSnackBar('个人资料功能开发中'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security,
            title: '安全设置',
            subtitle: '密码和安全选项',
            onTap: () => context.showSnackBar('安全设置功能开发中'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: '隐私设置',
            subtitle: '控制您的隐私选项',
            onTap: () => context.showSnackBar('隐私设置功能开发中'),
          ),

          const Divider(),

          // 通知设置
          _buildSectionHeader(context, '通知设置'),
          _buildSwitchTile(
            context,
            icon: Icons.notifications_outlined,
            title: '推送通知',
            subtitle: '接收应用推送通知',
            value: true,
            onChanged: (value) =>
                context.showSnackBar('通知设置已${value ? '开启' : '关闭'}'),
          ),
          _buildSwitchTile(
            context,
            icon: Icons.email_outlined,
            title: '邮件通知',
            subtitle: '接收邮件通知',
            value: false,
            onChanged: (value) =>
                context.showSnackBar('邮件通知已${value ? '开启' : '关闭'}'),
          ),

          const Divider(),

          // 其他设置
          _buildSectionHeader(context, '其他设置'),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: '帮助与支持',
            subtitle: '获取帮助和联系支持',
            onTap: () => _showHelpDialog(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: '关于应用',
            subtitle: '版本信息和许可证',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.bug_report_outlined,
            title: '反馈问题',
            subtitle: '报告问题或提供建议',
            onTap: () => context.showSnackBar('反馈功能开发中'),
          ),

          const Divider(),

          // 危险操作
          _buildSectionHeader(context, '数据管理'),
          _buildSettingsTile(
            context,
            icon: Icons.cleaning_services_outlined,
            title: '清除缓存',
            subtitle: '清理应用缓存数据',
            onTap: () => _showClearCacheDialog(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: '退出登录',
            subtitle: '退出当前账户',
            textColor: context.colorScheme.error,
            onTap: () => _showLogoutDialog(context),
          ),

          const SizedBox(height: AppConstants.paddingLarge),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingLarge,
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeModeTile(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    String themeModeText,
  ) {
    return ListTile(
      leading: Icon(context.isDarkMode ? Icons.dark_mode : Icons.light_mode),
      title: const Text('主题模式'),
      subtitle: Text(themeModeText),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeModeDialog(context, ref, themeMode),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    String localeText,
  ) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('语言'),
      subtitle: Text(localeText),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, ref, locale),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('跟随系统'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('浅色模式'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('深色模式'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: const Text('English'),
              value: const Locale('en', 'US'),
              groupValue: currentLocale,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<Locale>(
              title: const Text('中文'),
              value: const Locale('zh', 'CN'),
              groupValue: currentLocale,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助与支持'),
        content: const Text(
          'Flutter Template 是一个开源的 Flutter 项目模板。\n\n'
          '如果您遇到问题或需要帮助，可以通过以下方式联系我们：\n'
          '• GitHub Issues\n'
          '• 邮箱：support@example.com\n'
          '• 官方网站：https://example.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.flutter_dash,
          color: context.colorScheme.onPrimary,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'Flutter Template 是一个基于最佳实践的 Flutter 项目模板，'
          '集成了 Riverpod 状态管理、Dio 网络请求、SharedPreferences 本地存储等常用功能。',
        ),
      ],
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    context
        .showConfirmDialog(title: '清除缓存', content: '确定要清除应用缓存吗？这将删除所有临时数据。')
        .then((result) {
          if (result == true) {
            // 这里执行清除缓存的逻辑
            context.showSuccessSnackBar('缓存已清除');
          }
        });
  }

  void _showLogoutDialog(BuildContext context) {
    context.showConfirmDialog(title: '退出登录', content: '确定要退出当前账户吗？').then((
      result,
    ) {
      if (result == true) {
        // 这里执行退出登录的逻辑
        context.showSuccessSnackBar('已退出登录');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }
}
