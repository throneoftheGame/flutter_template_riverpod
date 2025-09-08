import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/particles_widget.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
// 新架构相关导入 - 使用 Clean Architecture 的三层架构
import '../../domain/entities/login_credential.dart';
import '../providers/auth_providers_config.dart';
import '../providers/auth_provider.dart'; // 导入 AuthState 和 AuthStatus

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // 输入控制器 - 保持不变，用于控制表单输入
  final _accountController = TextEditingController(); // 账号/邮箱输入控制器
  final _phoneController = TextEditingController(); // 手机号码输入控制器
  final _passwordController = TextEditingController(); // 密码输入控制器

  // UI 状态控制变量 - 这些状态只影响 UI 显示，不涉及业务逻辑
  bool _obscurePassword = true; // 密码可见性控制
  bool _isPhoneLogin = false; // 登录方式切换：false=账号/邮箱登录，true=手机号码登录

  // 表单验证错误提示信息 - 用于显示客户端验证错误
  String? _accountErrorText; // 账号/邮箱错误提示
  String? _phoneErrorText; // 手机号码错误提示
  String? _passwordErrorText; // 密码错误提示

  // 手机号码国家代码配置 - UI 配置数据，不变
  String _selectedCountryCode = '+86'; // 默认选择中国+86
  final List<Map<String, String>> _countryCodes = [
    {'code': '+86', 'name': '中国', 'digits': '11'},
    {'code': '+63', 'name': '菲律宾', 'digits': '11'},
    {'code': '+57', 'name': '哥伦比亚', 'digits': '10'},
  ];

  // 注意：移除了原有的 _isLoading 状态
  // 现在加载状态通过 AuthProviders.authLoading 来管理

  @override
  void dispose() {
    // 释放所有输入控制器资源，防止内存泄漏
    _accountController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听认证状态变化 - 使用新架构的状态管理
    ref.listen<AuthState>(AuthProviders.auth, (previous, next) {
      _handleAuthStateChange(context, previous, next);
    });

    // 获取当前的加载状态 - 从新架构的状态管理中获取
    final isLoading = ref.watch(AuthProviders.authLoading);

    return Scaffold(
      body: Stack(
        children: [
          // 渐变动画背景层 - 提供彩色渐变背景动画
          const Positioned.fill(child: AnimatedBackground()),

          // 粒子效果层 - 在背景上添加飘动的白色粒子效果
          const Positioned.fill(child: ParticlesWidget(30)),

          // 主要内容层 - 包含所有用户界面元素
          SafeArea(
            child: Column(
              children: [
                // 顶部导航栏 - 自定义白色导航栏
                _buildCustomAppBar(),

                // 登录表单内容区域 - 可滚动的主要内容
                Expanded(
                  child: LoadingOverlay(
                    isLoading: isLoading, // 使用新架构的加载状态
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Form(
                        key: _formKey, // 表单验证控制器
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo 和欢迎文字区域
                            _buildLogoSection(),
                            const SizedBox(height: AppConstants.paddingXLarge),

                            // 表单和登录按钮作为一个整体容器
                            _buildFormWithLoginButton(),

                            // 添加错误信息显示区域 - 显示来自新架构的错误信息
                            _buildArchitectureErrorDisplay(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 底部注册选项 - 固定在底部，不跟随页面滚动
                _buildBottomRegisterOption(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 自定义顶部导航栏
  ///
  /// 布局设计：
  /// - 使用 Stack 布局确保标题完全居中
  /// - 左侧：返回按钮 (Positioned)
  /// - 中间：登录标题 (Center) - 完全居中，不受左右元素影响
  /// - 右侧：语言切换按钮 (Positioned)
  ///
  /// 国际化实现说明：
  /// - 使用 AppLocalizations.of(context)! 获取当前语言环境的本地化实例
  /// - 标题文本使用 l10n.login 实现多语言支持
  /// - 右侧的语言切换下拉框可以实时切换中英文
  /// - 切换语言后，整个页面的文本会自动更新为对应语言
  Widget _buildCustomAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 56, // 设置固定高度，确保垂直居中
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        children: [
          // 左侧返回按钮
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),

          // 中间标题 - 使用 Center 确保完全居中
          Center(
            child: Text(
              l10n.login, // 使用国际化文本
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // 右侧语言切换按钮
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(child: _buildLanguageSwitchButton()),
          ),
        ],
      ),
    );
  }

  /// 构建语言切换下拉框
  /// 点击显示语言选择列表，支持中英文切换
  ///
  /// 国际化核心实现：
  /// 1. 使用 Consumer 监听 localeProvider 状态变化
  /// 2. 通过 ref.read(localeProvider.notifier).setLocale() 切换语言
  /// 3. 语言切换后会触发整个应用重建，所有使用 AppLocalizations 的文本都会更新
  /// 4. 下拉菜单中使用对勾图标显示当前选中的语言
  /// 5. 切换提示消息也使用国际化字符串，支持参数插值
  Widget _buildLanguageSwitchButton() {
    return Consumer(
      builder: (context, ref, child) {
        final locale = ref.watch(localeProvider);
        final isChineseLocale = locale.languageCode == 'zh';

        return PopupMenuButton<Locale>(
          // 下拉菜单项
          itemBuilder: (context) => [
            PopupMenuItem<Locale>(
              value: const Locale('zh', 'CN'),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: isChineseLocale
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('中文'),
                ],
              ),
            ),
            PopupMenuItem<Locale>(
              value: const Locale('en', 'US'),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: !isChineseLocale
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('English'),
                ],
              ),
            ),
          ],
          // 选择语言时的回调
          onSelected: (Locale selectedLocale) {
            if (selectedLocale != locale) {
              ref.read(localeProvider.notifier).setLocale(selectedLocale);

              // 显示切换提示 - 使用国际化字符串
              final isNowChinese = selectedLocale.languageCode == 'zh';
              final languageName = isNowChinese
                  ? AppLocalizations.of(context)!.chinese
                  : AppLocalizations.of(context)!.english;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    )!.switchedToLanguage(languageName),
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          // 下拉菜单样式
          color: Theme.of(context).colorScheme.surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          // 调整下拉菜单位置
          offset: const Offset(0, 8),
          // 自定义触发按钮 - 更符合header风格的设计 (child参数应该放在最后)
          child: Container(
            height: 36, // 增加高度，确保文本完全显示
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // 增加padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18), // 调整圆角以匹配新高度
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // 确保内容居中
              children: [
                Text(
                  isChineseLocale ? '中文' : 'EN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6), // 稍微增加间距
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建标题文字区域
  /// 移除了原有的 logo 图标，只保留简洁的文字标题
  /// 使用白色文字配合阴影效果，确保在动画背景上清晰可见
  Widget _buildLogoSection() {
    return Column(
      children: [
        // 添加顶部间距，为标题留出合适的空间
        const SizedBox(height: AppConstants.paddingLarge * 1.5),

        // 主标题文字 - 使用国际化字符串，支持多语言切换
        // 使用大号字体和粗体样式，突出显示主要功能
        Text(
          AppLocalizations.of(context)!.loginTitle,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white, // 白色文字确保在彩色背景上可见
            fontSize: 28, // 稍微增大字号，提升视觉重点
            shadows: [
              // 添加阴影效果，增强文字在动画背景上的可读性
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),

        // 标题下方间距，保持页面布局的视觉平衡
        const SizedBox(height: AppConstants.paddingMedium),
      ],
    );
  }

  /// 构建表单和登录按钮的整体容器
  /// 将表单输入区域和登录按钮组合成一个统一的容器
  /// 提供更好的视觉整体性和用户体验
  /// 适配亮色和暗色主题，使用主题相关的颜色，与home页面卡片样式保持一致
  ///
  /// 国际化实现：
  /// - 所有表单元素（标签、按钮、错误消息）都使用 AppLocalizations 获取本地化文本
  /// - 表单验证错误消息支持多语言显示
  /// - 支持带参数的国际化字符串（如手机号码位数验证）
  Widget _buildFormWithLoginButton() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingMedium),
            // 登录方式切换标签
            _buildLoginTypeTabs(),
            const SizedBox(height: AppConstants.paddingLarge),

            // 根据选择的登录方式显示不同的输入框
            _isPhoneLogin
                ? _buildPhoneLoginFields()
                : _buildAccountLoginFields(),

            const SizedBox(height: AppConstants.paddingMedium),

            // 密码输入框（两种登录方式共用）
            _buildPasswordField(),

            // 忘记密码链接
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
                child: Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: TextStyle(color: context.colorScheme.primary),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // 登录按钮 - 集成到表单容器内部
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  /// 构建底部注册选项
  /// 固定在屏幕底部，不跟随页面滚动
  /// 移除背景色，使用透明样式与动画背景融合
  Widget _buildBottomRegisterOption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.noAccount,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8), // 使用半透明白色文字
              shadows: [
                // 添加阴影确保在动画背景上可见
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _handleRegister,
            child: Text(
              AppLocalizations.of(context)!.pleaseRegister,
              style: TextStyle(
                color: context.colorScheme.primary, // 使用主题相关的文字颜色
                fontWeight: FontWeight.w600,
                shadows: [
                  // 添加阴影确保在动画背景上可见
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建登录方式切换标签
  /// 提供账号/邮箱登录和手机号码登录两个选项
  /// 适配亮色和暗色主题，优化亮色主题下的对比度和可读性
  Widget _buildLoginTypeTabs() {
    // 根据当前主题模式选择合适的背景色
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tabsBackgroundColor = isDarkMode
        ? context.colorScheme.surfaceContainerHighest
        : context.colorScheme.surfaceContainerHighest; // 亮色主题也使用相同颜色，确保对比度

    return Container(
      decoration: BoxDecoration(
        color: tabsBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          // 账号/邮箱登录标签
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPhoneLogin = false; // 切换到账号/邮箱登录
                  _clearErrorMessages(); // 清除之前的错误提示
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  // 选中状态：使用主题的primary颜色，未选中：透明
                  color: !_isPhoneLogin
                      ? context.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  boxShadow: !_isPhoneLogin
                      ? [
                          BoxShadow(
                            // 根据主题调整阴影颜色深度
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.2)
                                : context.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  AppLocalizations.of(context)!.accountEmailLogin,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // 选中状态：使用onPrimary颜色确保对比度，未选中：使用主题的onSurface颜色
                    color: !_isPhoneLogin
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onSurface,
                    fontWeight: !_isPhoneLogin
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          // 手机号码登录标签
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPhoneLogin = true; // 切换到手机号码登录
                  _clearErrorMessages(); // 清除之前的错误提示
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  // 选中状态：使用主题的primary颜色，未选中：透明
                  color: _isPhoneLogin
                      ? context.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  boxShadow: _isPhoneLogin
                      ? [
                          BoxShadow(
                            // 根据主题调整阴影颜色深度
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.2)
                                : context.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  AppLocalizations.of(context)!.phoneLogin,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // 选中状态：使用onPrimary颜色确保对比度，未选中：使用主题的onSurface颜色
                    color: _isPhoneLogin
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onSurface,
                    fontWeight: _isPhoneLogin
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账号/邮箱登录输入字段
  /// 支持账号或邮箱输入，包含失焦验证
  ///
  /// 修改说明：
  /// 1. 添加了验证失败时的红色边框显示
  /// 2. 使用TextFormField自带的errorText属性，支持动画效果
  /// 3. 移除了自定义的错误文本显示组件
  Widget _buildAccountLoginFields() {
    return TextFormField(
      controller: _accountController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.accountEmail,
        prefixIcon: const Icon(Icons.person_outline),
        // 修改：根据验证状态设置边框样式
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: _accountErrorText != null
              ? const BorderSide(color: Colors.red, width: 1.5)
              : BorderSide.none,
        ),
        // 修改：设置启用状态下的边框（用户交互时）
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: _accountErrorText != null
              ? const BorderSide(color: Colors.red, width: 1.5)
              : BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        // 修改：设置焦点状态下的边框
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: _accountErrorText != null
              ? const BorderSide(color: Colors.red, width: 2)
              : BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        // 修改：设置错误状态下的边框
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        // 修改：设置错误焦点状态下的边框
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        // 根据主题选择合适的填充颜色：使用主题相关的surface颜色，确保和谐统一
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? context.colorScheme.surfaceContainerHighest
            : context.colorScheme.surfaceContainerLow,
        // 修改：使用TextFormField自带的errorText属性，支持动画效果
        errorText: _accountErrorText,
        errorStyle: TextStyle(color: Colors.red[700], fontSize: 12),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        // 输入时清除错误提示
        if (_accountErrorText != null) {
          setState(() {
            _accountErrorText = null;
          });
        }
      },
      onFieldSubmitted: (value) {
        // 失焦时验证账号/邮箱（仅在非提交状态时进行验证，避免与登录按钮点击时的验证冲突）
        final isLoading = ref.read(AuthProviders.authLoading);
        if (!isLoading) {
          _validateAccount(value);
        }
      },
    );
  }

  /// 构建手机号码登录输入字段
  /// 包含国家代码选择和手机号码输入
  ///
  /// 修改说明：
  /// 1. 将手机号码输入框改为单独的Column，使用TextFormField自带的errorText
  /// 2. 添加了验证失败时的红色边框显示
  /// 3. 移除了自定义的错误文本显示组件
  /// 4. 保持国家代码选择器的原有样式
  Widget _buildPhoneLoginFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 手机号码输入框（带国家代码前缀）
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 国家代码选择下拉框
            Container(
              width: 100,
              child: DropdownButtonFormField<String>(
                value: _selectedCountryCode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                  ),
                  filled: true,
                  // 根据主题选择合适的填充颜色：使用主题相关的surface颜色，确保和谐统一
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? context.colorScheme.surfaceContainerHighest
                      : context.colorScheme.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: _countryCodes.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['code'],
                    child: Text(
                      country['code']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountryCode = value!; // 更新选中的国家代码
                    _phoneErrorText = null; // 清除手机号码错误提示
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            // 修改：手机号码输入框，添加红色边框和自带errorText
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  // 修改：根据验证状态设置边框样式
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    borderSide: _phoneErrorText != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide.none,
                  ),
                  // 修改：设置启用状态下的边框（用户交互时）
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    borderSide: _phoneErrorText != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  // 修改：设置焦点状态下的边框
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    borderSide: _phoneErrorText != null
                        ? const BorderSide(color: Colors.red, width: 2)
                        : BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                  ),
                  // 修改：设置错误状态下的边框
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  // 修改：设置错误焦点状态下的边框
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  // 根据主题选择合适的填充颜色：使用主题相关的surface颜色，确保和谐统一
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? context.colorScheme.surfaceContainerHighest
                      : context.colorScheme.surfaceContainerLow,
                  // 修改：使用TextFormField自带的errorText属性，支持动画效果
                  errorText: _phoneErrorText,
                  errorStyle: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  // 输入时清除错误提示
                  if (_phoneErrorText != null) {
                    setState(() {
                      _phoneErrorText = null;
                    });
                  }
                },
                onFieldSubmitted: (value) {
                  // 失焦时验证手机号码（仅在非提交状态时进行验证，避免与登录按钮点击时的验证冲突）
                  final isLoading = ref.read(AuthProviders.authLoading);
                  if (!isLoading) {
                    _validatePhone(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建密码输入字段
  /// 包含密码可见性切换和实时验证
  ///
  /// 修改说明：
  /// 1. 添加了验证失败时的红色边框显示
  /// 2. 使用TextFormField自带的errorText属性，支持动画效果
  /// 3. 移除了自定义的错误文本显示组件
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.password,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword; // 切换密码可见性
            });
          },
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        // 修改：根据验证状态设置边框样式
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: _passwordErrorText != null
              ? const BorderSide(color: Colors.red, width: 1.5)
              : BorderSide.none,
        ),
        // 修改：设置启用状态下的边框（用户交互时）
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: _passwordErrorText != null
              ? const BorderSide(color: Colors.red, width: 1.5)
              : BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        // 修改：设置焦点状态下的边框
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: _passwordErrorText != null
              ? const BorderSide(color: Colors.red, width: 2)
              : BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        // 修改：设置错误状态下的边框
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        // 修改：设置错误焦点状态下的边框
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        // 根据主题选择合适的填充颜色：使用主题相关的surface颜色，确保和谐统一
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? context.colorScheme.surfaceContainerHighest
            : context.colorScheme.surfaceContainerLow,
        // 修改：使用TextFormField自带的errorText属性，支持动画效果
        errorText: _passwordErrorText,
        errorStyle: TextStyle(color: Colors.red[700], fontSize: 12),
      ),
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        // 输入时实时验证密码格式（新的验证方法会自动处理状态更新）
        _validatePasswordFormat(value);
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  /// 构建登录按钮
  /// 简化样式，因为现在包含在表单容器内部
  /// 使用主题色背景和圆角设计，适配亮色和暗色主题
  ///
  /// 重构说明：
  /// - 原来使用本地的 _isLoading 状态
  /// - 现在使用新架构的 AuthProviders.authLoading 状态
  /// - 保持 UI 逻辑不变，只是数据源发生改变
  Widget _buildLoginButton() {
    // 从新架构获取加载状态
    final isLoading = ref.watch(AuthProviders.authLoading);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin, // 使用新架构的加载状态
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primary, // 使用主题主色
          foregroundColor: context.colorScheme.onPrimary, // 使用主题相关的文字颜色
          // 根据主题选择合适的禁用状态背景色
          disabledBackgroundColor:
              Theme.of(context).brightness == Brightness.dark
              ? context.colorScheme.surfaceContainerHighest
              : Colors.grey[300],
          elevation: 2, // 轻微阴影效果
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.login,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// 清除所有错误提示信息
  /// 在切换登录方式时调用
  void _clearErrorMessages() {
    setState(() {
      _accountErrorText = null;
      _phoneErrorText = null;
      _passwordErrorText = null;
    });
  }

  /// 验证账号/邮箱输入
  /// 检查是否为有效的邮箱格式或已注册的账号
  /// 返回验证结果，避免重复设置错误状态
  ///
  /// 国际化验证消息：
  /// - 所有验证错误消息都使用 AppLocalizations 获取对应语言的文本
  /// - 支持中英文错误提示的实时切换
  /// - 验证逻辑保持不变，只是显示的文本会根据当前语言环境变化
  bool _validateAccount(String value) {
    String? errorMessage;

    if (value.trim().isEmpty) {
      errorMessage = AppLocalizations.of(context)!.pleaseEnterAccountOrEmail;
    } else if (value.contains('@')) {
      // 邮箱格式验证
      if (!value.isValidEmail) {
        errorMessage = AppLocalizations.of(context)!.pleaseEnterValidEmail;
      } else if (!_isEmailRegistered(value)) {
        // 模拟检查邮箱是否已绑定账号（实际项目中应该调用API检查）
        errorMessage = AppLocalizations.of(context)!.emailNotLinked;
      }
    } else {
      // 账号验证 - 模拟检查账号是否已注册（实际项目中应该调用API检查）
      if (!_isAccountRegistered(value)) {
        errorMessage = AppLocalizations.of(context)!.accountNotRegistered;
      }
    }

    // 只有在错误信息发生变化时才更新状态，避免不必要的重建
    if (_accountErrorText != errorMessage) {
      setState(() {
        _accountErrorText = errorMessage;
      });
    }

    // 返回验证结果
    return errorMessage == null;
  }

  /// 验证手机号码输入
  /// 根据选择的国家代码检查手机号码位数
  /// 返回验证结果，避免重复设置错误状态
  bool _validatePhone(String value) {
    String? errorMessage;

    if (value.trim().isEmpty) {
      errorMessage = AppLocalizations.of(context)!.pleaseEnterPhoneNumber;
    } else {
      // 获取当前选中国家代码对应的位数要求
      final countryData = _countryCodes.firstWhere(
        (country) => country['code'] == _selectedCountryCode,
        orElse: () => {'digits': '11'},
      );
      final requiredDigits = int.parse(countryData['digits']!);

      // 检查手机号码位数
      if (value.length != requiredDigits) {
        errorMessage = AppLocalizations.of(
          context,
        )!.pleaseEnterDigitsPhone(requiredDigits);
      } else if (!RegExp(r'^\d+$').hasMatch(value)) {
        // 检查是否只包含数字
        errorMessage = AppLocalizations.of(context)!.phoneOnlyDigits;
      } else if (!_isPhoneRegistered(_selectedCountryCode + value)) {
        // 模拟检查手机号码是否已注册（实际项目中应该调用API检查）
        errorMessage = AppLocalizations.of(context)!.phoneNotRegistered;
      }
    }

    // 只有在错误信息发生变化时才更新状态，避免不必要的重建
    if (_phoneErrorText != errorMessage) {
      setState(() {
        _phoneErrorText = errorMessage;
      });
    }

    // 返回验证结果
    return errorMessage == null;
  }

  /// 验证密码格式
  /// 检查密码是否包含英文字母和数字
  /// 返回验证结果，避免重复设置错误状态
  bool _validatePasswordFormat(String value) {
    String? errorMessage;

    if (value.isNotEmpty) {
      // 检查密码是否包含英文字母和数字
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
      final hasDigit = RegExp(r'[0-9]').hasMatch(value);

      if (!hasLetter || !hasDigit) {
        errorMessage = AppLocalizations.of(context)!.passwordMustContain;
      }
    }
    // 如果密码为空，不显示格式错误（空值错误由其他验证处理）

    // 只有在错误信息发生变化时才更新状态，避免不必要的重建
    if (_passwordErrorText != errorMessage) {
      setState(() {
        _passwordErrorText = errorMessage;
      });
    }

    // 返回验证结果
    return errorMessage == null;
  }

  /// 模拟检查邮箱是否已注册绑定账号
  /// 实际项目中应该调用后端API
  bool _isEmailRegistered(String email) {
    // 模拟数据：假设这些邮箱已经绑定了账号
    final registeredEmails = [
      'test@example.com',
      'user@gmail.com',
      'admin@company.com',
    ];
    return registeredEmails.contains(email);
  }

  /// 模拟检查账号是否已注册
  /// 实际项目中应该调用后端API
  bool _isAccountRegistered(String account) {
    // 模拟数据：假设这些账号已经注册
    final registeredAccounts = ['admin', 'testuser', 'user123'];
    return registeredAccounts.contains(account);
  }

  /// 模拟检查手机号码是否已注册
  /// 实际项目中应该调用后端API
  bool _isPhoneRegistered(String fullPhoneNumber) {
    // 模拟数据：假设这些手机号码已经注册
    final registeredPhones = [
      '+8613800138000',
      '+8618888888888',
      '+6391234567890',
      '+5712345678901',
    ];
    return registeredPhones.contains(fullPhoneNumber);
  }

  /// 处理登录提交逻辑
  /// 根据当前登录方式执行相应的验证和登录流程
  ///
  /// 重构说明：
  /// - 原来使用模拟的 _performLogin 方法进行验证
  /// - 现在使用新架构的 AuthProviders.auth 进行真正的业务逻辑处理
  /// - 移除了本地的加载状态管理，由 AuthProvider 统一管理
  /// - 移除了手动的成功/失败弹窗，改为通过状态监听处理
  /// - 保持前端验证逻辑不变，确保用户体验
  Future<void> _handleLogin() async {
    // 隐藏键盘
    context.hideKeyboard();

    // 清除之前的错误提示，避免与新的验证结果冲突
    _clearErrorMessages();

    // 先进行前端验证（在清除错误提示后进行，确保显示最新的验证结果）
    if (!_validateBeforeSubmit()) {
      return;
    }

    try {
      // 获取密码
      final password = _passwordController.text.trim();

      // 根据登录方式创建登录凭证实体 - 使用新架构的领域实体
      final LoginCredential credential;

      if (_isPhoneLogin) {
        // 手机号登录：使用 LoginCredential.phone 工厂构造函数
        final phoneNumber = _phoneController.text.trim();
        credential = LoginCredential.phone(
          phoneNumber: phoneNumber,
          password: password,
          countryCode: _selectedCountryCode,
        );
      } else {
        // 账号/邮箱登录：自动判断是邮箱还是用户名
        final accountInput = _accountController.text.trim();

        // 简单的邮箱格式检查
        final isEmail = accountInput.contains('@');

        if (isEmail) {
          credential = LoginCredential.email(
            email: accountInput,
            password: password,
          );
        } else {
          credential = LoginCredential.username(
            username: accountInput,
            password: password,
          );
        }
      }

      // 使用新架构的认证提供者执行登录
      // 注意：不需要手动管理加载状态和错误处理
      // 这些都由 AuthProvider 统一管理，UI 通过状态监听响应
      final success = await ref
          .read(AuthProviders.auth.notifier)
          .login(credential);

      // 登录结果处理通过 _handleAuthStateChange 方法进行
      // 这里不需要手动处理成功/失败逻辑
      print('登录操作完成，结果: $success');
    } catch (e) {
      // 捕获未预期的异常
      // 新架构中，大部分异常都会被 AuthProvider 处理
      // 这里只处理真正意外的异常
      print('登录过程中发生未预期的异常: $e');

      if (mounted) {
        context.showErrorSnackBar('登录过程中发生未知错误，请重试');
      }
    }
  }

  /// 登录前的前端验证
  /// 确保所有必要字段都已正确填写且无错误
  /// 使用统一的验证逻辑，避免重复验证和错误提示
  bool _validateBeforeSubmit() {
    bool isValid = true;

    // 验证登录凭证（账号/邮箱或手机号码）
    if (_isPhoneLogin) {
      final phone = _phoneController.text.trim();
      // 使用统一的验证方法，该方法会处理错误状态的设置
      if (!_validatePhone(phone)) {
        isValid = false;
      }
    } else {
      final account = _accountController.text.trim();
      // 使用统一的验证方法，该方法会处理错误状态的设置
      if (!_validateAccount(account)) {
        isValid = false;
      }
    }

    // 验证密码
    final password = _passwordController.text;
    if (password.isEmpty) {
      // 处理密码为空的情况（格式验证不处理空值）
      setState(() {
        _passwordErrorText = AppLocalizations.of(context)!.pleaseEnterPassword;
      });
      isValid = false;
    } else {
      // 使用统一的验证方法，该方法会处理错误状态的设置
      if (!_validatePasswordFormat(password)) {
        isValid = false;
      }
    }

    return isValid;
  }

  /// 处理认证状态变化
  ///
  /// 新架构添加的方法：监听认证状态变化并做出相应的 UI 响应
  ///
  /// 参数：
  /// - [context] 当前的构建上下文
  /// - [previous] 前一个认证状态
  /// - [next] 当前的认证状态
  ///
  /// 业务逻辑：
  /// 1. 登录成功时导航到主页面
  /// 2. 登录失败时显示错误提示
  /// 3. 其他状态变化的处理
  void _handleAuthStateChange(
    BuildContext context,
    AuthState? previous,
    AuthState next,
  ) {
    // 登录成功处理
    if (previous?.status != AuthStatus.authenticated &&
        next.status == AuthStatus.authenticated) {
      // 显示成功提示
      context.showSuccessSnackBar(AppLocalizations.of(context)!.loginSuccess);

      // 延迟导航，让用户看到成功提示
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      });
    }

    // 登录失败处理
    if (previous?.status == AuthStatus.loggingIn &&
        next.status == AuthStatus.unauthenticated &&
        next.hasError) {
      // 不需要显示错误，因为 _buildArchitectureErrorDisplay 会处理
      // 这里可以添加其他失败后的逻辑，比如清除敏感信息
      _passwordController.clear(); // 清除密码输入
    }
  }

  /// 构建新架构的错误信息显示组件
  ///
  /// 新架构添加的方法：显示来自 AuthProvider 的错误信息
  ///
  /// 特点：
  /// 1. 自动监听认证状态中的错误信息
  /// 2. 只在有错误时显示
  /// 3. 提供清除错误的功能
  /// 4. 使用统一的错误样式
  Widget _buildArchitectureErrorDisplay() {
    return Consumer(
      builder: (context, ref, child) {
        final authError = ref.watch(AuthProviders.authError);

        if (authError == null || authError.isEmpty) {
          return const SizedBox.shrink(); // 没有错误时不显示
        }

        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            border: Border.all(color: Colors.red[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  authError,
                  style: TextStyle(color: Colors.red[700], fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () {
                  // 清除错误信息
                  ref.read(AuthProviders.auth.notifier).clearError();
                },
                icon: Icon(Icons.close, color: Colors.red[700], size: 18),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }

  // 注意：以下方法在新架构中已被移除
  // - _performLogin: 业务逻辑已迁移到 AuthProvider
  // - _showSuccessDialog: 使用 SnackBar 和状态监听替代
  // - _showErrorDialog: 使用统一的错误显示组件替代

  /// 处理忘记密码
  /// 跳转到密码重置页面或显示相关提示
  void _handleForgotPassword() {
    context.showSnackBar(
      AppLocalizations.of(context)!.forgotPasswordInDevelopment,
    );
  }

  /// 处理注册按钮点击
  /// 跳转到注册页面
  void _handleRegister() {
    context.showSnackBar(AppLocalizations.of(context)!.registerInDevelopment);
    // 实际项目中应该跳转到注册页面
    // Navigator.of(context).pushNamed('/register');
  }
}
