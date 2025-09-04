import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/failures.dart';

/// 错误显示组件
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.failure,
    this.onRetry,
    this.showDetails = false,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getErrorIcon(), size: 64, color: theme.colorScheme.error),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              _getErrorTitle(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              failure.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (showDetails && failure.code != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                '错误代码: ${failure.code}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return Icons.wifi_off;
      case ServerFailure:
        return Icons.error_outline;
      case AuthFailure:
        return Icons.lock_outline;
      case CacheFailure:
        return Icons.storage;
      case ParseFailure:
        return Icons.warning_amber;
      case BusinessFailure:
        return Icons.info_outline;
      default:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle() {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return '网络错误';
      case ServerFailure:
        return '服务器错误';
      case AuthFailure:
        return '认证失败';
      case CacheFailure:
        return '存储错误';
      case ParseFailure:
        return '数据解析错误';
      case BusinessFailure:
        return '业务错误';
      default:
        return '未知错误';
    }
  }
}

/// 简单错误显示组件
class SimpleErrorWidget extends StatelessWidget {
  const SimpleErrorWidget({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppConstants.paddingSmall),
            TextButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ],
      ),
    );
  }
}
