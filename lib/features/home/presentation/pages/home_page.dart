import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/environment_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeModeText = ref.watch(themeModeTextProvider(context));
    final localeText = ref.watch(localeTextProvider(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed('/settings');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            _buildWelcomeCard(context, l10n),
            const SizedBox(height: AppConstants.paddingMedium),

            // 主题设置卡片
            _buildThemeCard(context, ref, themeModeText, l10n),
            const SizedBox(height: AppConstants.paddingMedium),

            // 语言设置卡片
            _buildLanguageCard(context, ref, localeText, l10n),
            const SizedBox(height: AppConstants.paddingMedium),

            // 功能演示卡片
            _buildDemoCard(context, l10n),
            const SizedBox(height: AppConstants.paddingMedium),

            // 快捷操作卡片
            _buildQuickActionsCard(context, l10n),
            const SizedBox(height: AppConstants.paddingMedium),

            // 环境信息卡片（非正式环境显示）
            const EnvironmentInfoCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.showSuccessSnackBar('Hello Flutter Template!');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.waving_hand,
                  color: context.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  l10n.welcome,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              l10n.welcomeMessage,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    WidgetRef ref,
    String themeModeText,
    AppLocalizations l10n,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          context.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: context.colorScheme.primary,
        ),
        title: Text(l10n.themeMode),
        subtitle: Text(themeModeText),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(themeModeProvider.notifier).toggleThemeMode();
        },
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    WidgetRef ref,
    String localeText,
    AppLocalizations l10n,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.language, color: context.colorScheme.primary),
        title: Text(l10n.languageSettings),
        subtitle: Text(localeText),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(localeProvider.notifier).toggleLocale();
        },
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.featureDemo,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showLoadingDemo(context, l10n);
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.loadingDemo),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDialogDemo(context, l10n);
                    },
                    icon: const Icon(Icons.info),
                    label: Text(l10n.dialog),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _showBottomSheetDemo(context, l10n);
                    },
                    icon: const Icon(Icons.vertical_align_bottom),
                    label: Text(l10n.bottomSheet),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      context.pushNamed('/login');
                    },
                    icon: const Icon(Icons.login),
                    label: Text(l10n.loginPage),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppConstants.paddingSmall,
              crossAxisSpacing: AppConstants.paddingSmall,
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.person,
                  label: l10n.profile,
                  onTap: () =>
                      context.showSnackBar(l10n.profileFeatureInDevelopment),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.notifications,
                  label: l10n.notifications,
                  onTap: () => context.showSnackBar(
                    l10n.notificationFeatureInDevelopment,
                  ),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.help,
                  label: l10n.help,
                  onTap: () =>
                      context.showSnackBar(l10n.helpFeatureInDevelopment),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: context.colorScheme.primary),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              label,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLoadingDemo(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: LoadingWidget(message: l10n.loading),
        ),
      ),
    );

    // 3秒后关闭
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        context.showSuccessSnackBar(l10n.loadingComplete);
      }
    });
  }

  void _showDialogDemo(BuildContext context, AppLocalizations l10n) {
    context
        .showConfirmDialog(
          title: l10n.confirmOperation,
          content: l10n.confirmDialogMessage,
        )
        .then((result) {
          if (result == true) {
            context.showSuccessSnackBar(l10n.youClickedConfirm);
          } else if (result == false) {
            context.showSnackBar(l10n.youClickedCancel);
          }
        });
  }

  void _showBottomSheetDemo(BuildContext context, AppLocalizations l10n) {
    context.showAppBottomSheet(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.bottomSheetExample, style: context.textTheme.titleLarge),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              l10n.bottomSheetMessage,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.showSuccessSnackBar(l10n.operationSuccess);
                    },
                    child: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
