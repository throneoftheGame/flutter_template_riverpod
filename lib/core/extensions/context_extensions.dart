import 'package:flutter/material.dart';

/// BuildContext 扩展方法
extension ContextExtensions on BuildContext {
  /// 主题
  ThemeData get theme => Theme.of(this);

  /// 颜色方案
  ColorScheme get colorScheme => theme.colorScheme;

  /// 文本主题
  TextTheme get textTheme => theme.textTheme;

  /// 媒体查询
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// 屏幕尺寸
  Size get screenSize => mediaQuery.size;

  /// 屏幕宽度
  double get screenWidth => screenSize.width;

  /// 屏幕高度
  double get screenHeight => screenSize.height;

  /// 是否为横屏
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// 是否为竖屏
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// 状态栏高度
  double get statusBarHeight => mediaQuery.padding.top;

  /// 底部安全区域高度
  double get bottomPadding => mediaQuery.padding.bottom;

  /// 是否为暗色主题
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// 是否为浅色主题
  bool get isLightMode => theme.brightness == Brightness.light;

  /// 是否为小屏幕设备 (< 600dp)
  bool get isSmallScreen => screenWidth < 600;

  /// 是否为中等屏幕设备 (600dp - 840dp)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 840;

  /// 是否为大屏幕设备 (>= 840dp)
  bool get isLargeScreen => screenWidth >= 840;

  /// 是否为平板
  bool get isTablet => screenWidth >= 600;

  /// 是否为手机
  bool get isMobile => screenWidth < 600;

  /// 显示SnackBar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// 显示成功消息
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.primary);
  }

  /// 显示错误消息
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }

  /// 显示警告消息
  void showWarningSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.orange);
  }

  /// 显示对话框
  Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }

  /// 显示确认对话框
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
  }) {
    return showAppDialog<bool>(
      child: AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(this).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(this).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 显示底部弹框
  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => child,
    );
  }

  /// 隐藏键盘
  void hideKeyboard() {
    final currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }

  /// 导航到指定页面
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// 替换当前页面
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// 清空导航栈并导航到指定页面
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// 返回上一页
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// 是否可以返回上一页
  bool get canPop => Navigator.of(this).canPop();
}
