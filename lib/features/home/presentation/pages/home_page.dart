import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final themeModeText = ref.watch(themeModeTextProvider);
    final localeText = ref.watch(localeTextProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Template'),
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
            _buildWelcomeCard(context),
            const SizedBox(height: AppConstants.paddingMedium),

            // 主题设置卡片
            _buildThemeCard(context, ref, themeModeText),
            const SizedBox(height: AppConstants.paddingMedium),

            // 语言设置卡片
            _buildLanguageCard(context, ref, localeText),
            const SizedBox(height: AppConstants.paddingMedium),

            // 功能演示卡片
            _buildDemoCard(context),
            const SizedBox(height: AppConstants.paddingMedium),

            // 快捷操作卡片
            _buildQuickActionsCard(context),
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

  Widget _buildWelcomeCard(BuildContext context) {
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
                  '欢迎使用',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Flutter Template 是一个基于 Riverpod + Dio + SharedPreferences 的快速开发模板，'
              '集成了常用的功能模块和最佳实践，帮助您快速开始新项目的开发。',
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
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          context.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: context.colorScheme.primary,
        ),
        title: const Text('主题模式'),
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
  ) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.language, color: context.colorScheme.primary),
        title: const Text('语言设置'),
        subtitle: Text(localeText),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(localeProvider.notifier).toggleLocale();
        },
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '功能演示',
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
                      _showLoadingDemo(context);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('加载演示'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDialogDemo(context);
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('对话框'),
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
                      _showBottomSheetDemo(context);
                    },
                    icon: const Icon(Icons.vertical_align_bottom),
                    label: const Text('底部弹框'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      context.pushNamed('/login');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('登录页面'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快捷操作',
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
                  label: '个人中心',
                  onTap: () => context.showSnackBar('个人中心功能开发中'),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.notifications,
                  label: '通知',
                  onTap: () => context.showSnackBar('通知功能开发中'),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.help,
                  label: '帮助',
                  onTap: () => context.showSnackBar('帮助功能开发中'),
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

  void _showLoadingDemo(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: LoadingWidget(message: '正在加载中...'),
        ),
      ),
    );

    // 3秒后关闭
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        context.showSuccessSnackBar('加载完成！');
      }
    });
  }

  void _showDialogDemo(BuildContext context) {
    context
        .showConfirmDialog(title: '确认操作', content: '这是一个示例对话框，您确定要继续吗？')
        .then((result) {
          if (result == true) {
            context.showSuccessSnackBar('您点击了确定');
          } else if (result == false) {
            context.showSnackBar('您点击了取消');
          }
        });
  }

  void _showBottomSheetDemo(BuildContext context) {
    context.showAppBottomSheet(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('底部弹框示例', style: context.textTheme.titleLarge),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              '这是一个从底部弹出的弹框，可以用来显示更多选项或表单内容。',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.showSuccessSnackBar('操作成功！');
                    },
                    child: const Text('确定'),
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
