import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/login_credential.dart';
import '../providers/auth_provider.dart';

/// 登录页面示例
///
/// 展示如何使用新的三层架构进行登录功能开发
/// 特点：
/// 1. 使用 Clean Architecture 的用例和仓库
/// 2. 通过 Riverpod Provider 管理状态
/// 3. 清晰的业务逻辑分离
/// 4. 完整的错误处理和用户反馈
///
/// 注意：这是一个示例文件，展示新架构的使用方法
/// 实际项目中应该根据具体需求进行调整
class LoginPageExample extends ConsumerStatefulWidget {
  const LoginPageExample({super.key});

  @override
  ConsumerState<LoginPageExample> createState() => _LoginPageExampleState();
}

class _LoginPageExampleState extends ConsumerState<LoginPageExample> {
  /// 表单控制器
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// 登录类型选择
  LoginType _selectedLoginType = LoginType.email;

  /// 密码可见性控制
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 监听认证状态变化
    ref.listen<AuthState>(authProvider, (previous, next) {
      _handleAuthStateChange(context, previous, next, l10n);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.login), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题区域
                _buildHeaderSection(l10n),
                const SizedBox(height: 32),

                // 登录类型选择
                _buildLoginTypeSelector(l10n),
                const SizedBox(height: 24),

                // 输入表单
                _buildInputFields(l10n),
                const SizedBox(height: 24),

                // 登录按钮
                _buildLoginButton(l10n),
                const SizedBox(height: 16),

                // 错误信息显示
                _buildErrorDisplay(),

                const Spacer(),

                // 注册链接
                _buildRegisterLink(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建标题区域
  ///
  /// 显示欢迎信息和说明文字
  Widget _buildHeaderSection(AppLocalizations l10n) {
    return Column(
      children: [
        Icon(Icons.lock_outline, size: 80, color: context.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          l10n.loginTitle,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '使用 Clean Architecture 的登录示例',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 构建登录类型选择器
  ///
  /// 让用户选择使用邮箱还是用户名登录
  Widget _buildLoginTypeSelector(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('登录方式', style: context.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<LoginType>(
                    title: Text(l10n.accountEmail),
                    value: LoginType.email,
                    groupValue: _selectedLoginType,
                    onChanged: (value) {
                      setState(() {
                        _selectedLoginType = value!;
                        _emailController.clear();
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<LoginType>(
                    title: const Text('用户名'),
                    value: LoginType.username,
                    groupValue: _selectedLoginType,
                    onChanged: (value) {
                      setState(() {
                        _selectedLoginType = value!;
                        _emailController.clear();
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建输入字段
  ///
  /// 根据选择的登录类型显示相应的输入框
  Widget _buildInputFields(AppLocalizations l10n) {
    return Column(
      children: [
        // 邮箱/用户名输入框
        TextFormField(
          controller: _emailController,
          keyboardType: _selectedLoginType == LoginType.email
              ? TextInputType.emailAddress
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: _selectedLoginType == LoginType.email
                ? l10n.accountEmail
                : '用户名',
            prefixIcon: Icon(
              _selectedLoginType == LoginType.email
                  ? Icons.email_outlined
                  : Icons.person_outline,
            ),
            border: const OutlineInputBorder(),
          ),
          validator: (value) => _validateCredential(value, l10n),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // 密码输入框
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.password,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
          validator: (value) => _validatePassword(value, l10n),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  /// 构建登录按钮
  ///
  /// 显示登录按钮和加载状态
  Widget _buildLoginButton(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);
        final isLoading = authState.status == AuthStatus.loggingIn;

        return ElevatedButton(
          onPressed: isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.login, style: const TextStyle(fontSize: 16)),
        );
      },
    );
  }

  /// 构建错误信息显示
  ///
  /// 显示登录过程中的错误信息
  Widget _buildErrorDisplay() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        if (!authState.hasError) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: context.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  authState.error!,
                  style: TextStyle(
                    color: context.colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  ref.read(authProvider.notifier).clearError();
                },
                color: context.colorScheme.error,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建注册链接
  ///
  /// 显示注册入口
  Widget _buildRegisterLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.noAccount),
        TextButton(
          onPressed: () {
            // 导航到注册页面
            context.showSnackBar('注册功能开发中');
          },
          child: Text(l10n.pleaseRegister),
        ),
      ],
    );
  }

  /// 验证登录凭证
  ///
  /// 根据登录类型验证输入的凭证格式
  String? _validateCredential(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return _selectedLoginType == LoginType.email
          ? l10n.pleaseEnterAccountOrEmail
          : '请输入用户名';
    }

    if (_selectedLoginType == LoginType.email) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(value.trim())) {
        return l10n.pleaseEnterValidEmail;
      }
    } else {
      // 用户名验证
      if (value.trim().length < 3) {
        return '用户名至少3个字符';
      }
      if (value.trim().length > 20) {
        return '用户名最多20个字符';
      }
      final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
      if (!usernameRegex.hasMatch(value.trim())) {
        return '用户名只能包含字母、数字和下划线';
      }
    }

    return null;
  }

  /// 验证密码
  ///
  /// 检查密码格式和强度
  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterPassword;
    }

    if (value.length < 6) {
      return '密码至少6个字符';
    }

    // 检查是否包含字母和数字
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);

    if (!hasLetter || !hasDigit) {
      return l10n.passwordMustContain;
    }

    return null;
  }

  /// 处理登录操作
  ///
  /// 验证表单并执行登录逻辑
  Future<void> _handleLogin() async {
    // 清除之前的错误
    ref.read(authProvider.notifier).clearError();

    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 创建登录凭证
    final credential = _selectedLoginType == LoginType.email
        ? LoginCredential.email(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
        : LoginCredential.username(
            username: _emailController.text.trim(),
            password: _passwordController.text,
          );

    // 执行登录
    final success = await ref.read(authProvider.notifier).login(credential);

    if (success) {
      // 登录成功，显示成功消息
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.showSuccessSnackBar(l10n.loginSuccess);
      }
    }
    // 登录失败的错误处理在 _handleAuthStateChange 中进行
  }

  /// 处理认证状态变化
  ///
  /// 监听认证状态变化并做出相应的 UI 反应
  void _handleAuthStateChange(
    BuildContext context,
    AuthState? previous,
    AuthState next,
    AppLocalizations l10n,
  ) {
    // 登录成功
    if (previous?.status != AuthStatus.authenticated &&
        next.status == AuthStatus.authenticated) {
      // 可以在这里导航到主页面
      // Navigator.of(context).pushReplacementNamed('/home');
      print('登录成功，用户: ${next.user?.email}');
    }

    // 登录失败
    if (previous?.status == AuthStatus.loggingIn &&
        next.status == AuthStatus.unauthenticated &&
        next.hasError) {
      // 错误信息会通过 _buildErrorDisplay 显示
      print('登录失败: ${next.error}');
    }
  }
}

/// 使用说明和架构解释
/// 
/// 这个示例展示了如何使用新的三层架构：
/// 
/// 1. **Domain Layer (领域层)**:
///    - `LoginCredential`: 登录凭证实体，包含业务规则
///    - `User`: 用户实体，包含用户相关的业务逻辑
///    - `LoginUseCase`: 登录用例，包含完整的登录业务流程
///    - `AuthRepository`: 认证仓库接口，定义数据操作契约
/// 
/// 2. **Data Layer (数据层)**:
///    - `UserModel`: 用户数据模型，处理 JSON 序列化
///    - `LoginRequestModel`: 登录请求模型，格式化 API 请求
///    - `AuthRemoteDataSource`: 远程数据源，处理网络请求
///    - `AuthLocalDataSource`: 本地数据源，处理本地存储
///    - `AuthRepositoryImpl`: 仓库实现，协调远程和本地数据源
/// 
/// 3. **Presentation Layer (表现层)**:
///    - `AuthProvider`: 状态管理，使用 Riverpod 管理认证状态
///    - `LoginPageExample`: UI 页面，处理用户交互和显示
/// 
/// **优势**:
/// - **职责分离**: 每层只关心自己的职责
/// - **可测试性**: 每层都可以独立测试
/// - **可维护性**: 修改一层不会影响其他层
/// - **可扩展性**: 容易添加新功能或修改现有功能
/// - **依赖倒置**: 高层模块不依赖低层模块，都依赖抽象
/// 
/// **使用方法**:
/// 1. UI 层通过 Provider 调用业务逻辑
/// 2. Provider 调用 UseCase 执行业务操作
/// 3. UseCase 调用 Repository 接口
/// 4. Repository 实现协调数据源完成操作
/// 5. 结果通过相同路径返回到 UI 层
