import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/config/app_environment.dart';

/// 环境信息横幅组件
/// 在非正式环境下显示当前环境信息
class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({
    super.key,
    required this.child,
    this.style = EnvironmentBannerStyle.topRight,
  });

  final Widget child;
  final EnvironmentBannerStyle style;

  /// 环境横幅样式
  static const topRight = EnvironmentBannerStyle.topRight;
  static const topLeft = EnvironmentBannerStyle.topLeft;
  static const bottomRight = EnvironmentBannerStyle.bottomRight;

  @override
  Widget build(BuildContext context) {
    // 正式环境不显示横幅
    if (AppConfig.instance.isProduction) {
      return child;
    }

    // 使用 Stack 来确保环境标识不被遮挡
    return Stack(
      children: [
        child,
        // 环境标识横幅
        _buildEnvironmentTag(context),
      ],
    );
  }

  /// 构建环境标签
  Widget _buildEnvironmentTag(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Positioned(
      top: _getTopPosition(statusBarHeight),
      left: _getLeftPosition(),
      right: _getRightPosition(),
      bottom: _getBottomPosition(),
      child: IgnorePointer(
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getBannerColor(),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              AppConfig.instance.environment.displayName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 获取顶部位置
  double? _getTopPosition(double statusBarHeight) {
    switch (style) {
      case EnvironmentBannerStyle.topRight:
      case EnvironmentBannerStyle.topLeft:
        return statusBarHeight + 10;
      case EnvironmentBannerStyle.bottomRight:
        return null;
    }
  }

  /// 获取左侧位置
  double? _getLeftPosition() {
    switch (style) {
      case EnvironmentBannerStyle.topLeft:
        return 10;
      case EnvironmentBannerStyle.topRight:
      case EnvironmentBannerStyle.bottomRight:
        return null;
    }
  }

  /// 获取右侧位置
  double? _getRightPosition() {
    switch (style) {
      case EnvironmentBannerStyle.topRight:
      case EnvironmentBannerStyle.bottomRight:
        return 10;
      case EnvironmentBannerStyle.topLeft:
        return null;
    }
  }

  /// 获取底部位置
  double? _getBottomPosition() {
    switch (style) {
      case EnvironmentBannerStyle.bottomRight:
        return 100; // 避免与FAB冲突
      case EnvironmentBannerStyle.topRight:
      case EnvironmentBannerStyle.topLeft:
        return null;
    }
  }

  /// 根据环境获取横幅颜色
  Color _getBannerColor() {
    switch (AppConfig.instance.environment) {
      case AppEnvironment.development:
        return Colors.green;
      case AppEnvironment.staging:
        return Colors.orange;
      case AppEnvironment.production:
        return Colors.red;
    }
  }
}

/// 环境信息卡片组件
class EnvironmentInfoCard extends StatelessWidget {
  const EnvironmentInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: _getEnvironmentColor()),
                const SizedBox(width: 8),
                Text(
                  '环境信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('环境', config.environment.displayName),
            _buildInfoRow('应用名称', config.appName),
            _buildInfoRow('API地址', config.apiBaseUrl),
            _buildInfoRow('超时时间', '${config.apiTimeout}ms'),
            _buildInfoRow('日志启用', config.enableLogging ? '是' : '否'),
            _buildInfoRow('崩溃统计', config.enableCrashlytics ? '是' : '否'),
            _buildInfoRow('数据统计', config.enableAnalytics ? '是' : '否'),
            if (config.isDebugMode) ...[
              const Divider(),
              Text(
                '调试信息',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('性能叠加层', config.showPerformanceOverlay ? '是' : '否'),
              _buildInfoRow(
                '调试横幅',
                config.debugShowCheckedModeBanner ? '是' : '否',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEnvironmentColor() {
    switch (AppConfig.instance.environment) {
      case AppEnvironment.development:
        return Colors.green;
      case AppEnvironment.staging:
        return Colors.orange;
      case AppEnvironment.production:
        return Colors.blue;
    }
  }
}

/// 环境切换对话框（仅开发环境可用）
class EnvironmentSwitchDialog extends StatelessWidget {
  const EnvironmentSwitchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // 只在开发环境显示切换功能
    if (!AppConfig.instance.isDevelopment) {
      return const SizedBox.shrink();
    }

    return AlertDialog(
      title: const Text('切换环境'),
      content: const Text('环境切换需要重启应用才能生效'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // 这里可以添加环境切换逻辑
            // 实际项目中可能需要重启应用或显示提示
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('环境切换功能需要配合构建脚本使用')));
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}

/// 快速环境信息显示组件
class QuickEnvironmentInfo extends StatelessWidget {
  const QuickEnvironmentInfo({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppConfig.instance.isProduction) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getEnvironmentColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getEnvironmentColor().withOpacity(0.3)),
      ),
      child: Text(
        AppConfig.instance.environment.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getEnvironmentColor(),
        ),
      ),
    );
  }

  Color _getEnvironmentColor() {
    switch (AppConfig.instance.environment) {
      case AppEnvironment.development:
        return Colors.green;
      case AppEnvironment.staging:
        return Colors.orange;
      case AppEnvironment.production:
        return Colors.blue;
    }
  }
}

/// 环境横幅样式枚举
enum EnvironmentBannerStyle {
  /// 右上角
  topRight,
  /// 左上角
  topLeft,
  /// 右下角
  bottomRight,
}
