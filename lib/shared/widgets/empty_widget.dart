import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// 空状态显示组件
class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = '暂无数据',
    this.message = '这里还没有任何内容',
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// 搜索空结果组件
class SearchEmptyWidget extends StatelessWidget {
  const SearchEmptyWidget({super.key, required this.searchTerm, this.onClear});

  final String searchTerm;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.search_off,
      title: '未找到结果',
      message: '没有找到与"$searchTerm"相关的内容',
      actionText: onClear != null ? '清除搜索' : null,
      onAction: onClear,
    );
  }
}

/// 网络空状态组件
class NetworkEmptyWidget extends StatelessWidget {
  const NetworkEmptyWidget({super.key, this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.cloud_off,
      title: '无法加载数据',
      message: '请检查网络连接后重试',
      actionText: onRefresh != null ? '刷新' : null,
      onAction: onRefresh,
    );
  }
}
