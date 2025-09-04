import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录'), centerTitle: true),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo 区域
                _buildLogoSection(),
                const SizedBox(height: AppConstants.paddingXLarge),

                // 表单区域
                _buildFormSection(),
                const SizedBox(height: AppConstants.paddingLarge),

                // 登录按钮
                _buildLoginButton(),
                const SizedBox(height: AppConstants.paddingMedium),

                // 其他选项
                _buildOtherOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 50,
            color: context.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          '欢迎回来',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          '请登录您的账户',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        // 用户名输入框
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: '用户名/邮箱',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value.isNullOrEmpty) {
              return '请输入用户名或邮箱';
            }
            if (value!.contains('@') && !value.isValidEmail) {
              return '请输入有效的邮箱地址';
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // 密码输入框
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: '密码',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          validator: (value) {
            if (value.isNullOrEmpty) {
              return '请输入密码';
            }
            if (value!.length < 6) {
              return '密码长度至少为6位';
            }
            return null;
          },
        ),

        // 忘记密码
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleForgotPassword,
            child: const Text('忘记密码？'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
      child: const Text(
        '登录',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildOtherOptions() {
    return Column(
      children: [
        // 分割线
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Text(
                '或者',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // 第三方登录按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialLoginButton(
              icon: Icons.g_mobiledata,
              label: 'Google',
              onPressed: () => _handleSocialLogin('Google'),
            ),
            _buildSocialLoginButton(
              icon: Icons.apple,
              label: 'Apple',
              onPressed: () => _handleSocialLogin('Apple'),
            ),
            _buildSocialLoginButton(
              icon: Icons.wechat,
              label: '微信',
              onPressed: () => _handleSocialLogin('WeChat'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingLarge),

        // 注册链接
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '还没有账户？',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            TextButton(onPressed: _handleRegister, child: const Text('立即注册')),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    context.hideKeyboard();

    try {
      // 模拟登录请求
      await Future.delayed(const Duration(seconds: 2));

      final username = _usernameController.text.trim();

      // 简单的模拟登录逻辑
      if (username == 'admin' && _passwordController.text == '123456') {
        if (mounted) {
          context.showSuccessSnackBar('登录成功！');
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else {
        if (mounted) {
          context.showErrorSnackBar('用户名或密码错误');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('登录失败：${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    context.showSnackBar('忘记密码功能开发中');
  }

  void _handleSocialLogin(String platform) {
    context.showSnackBar('$platform 登录功能开发中');
  }

  void _handleRegister() {
    context.showSnackBar('注册功能开发中');
  }
}
