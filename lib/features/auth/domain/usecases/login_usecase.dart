import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/login_credential.dart';
import '../repositories/auth_repository.dart';

/// 登录用例
///
/// 这是领域层的用例类，封装了登录的完整业务逻辑
/// 特点：
/// 1. 包含登录前的验证逻辑
/// 2. 调用仓库进行实际的登录操作
/// 3. 处理登录后的业务逻辑
/// 4. 单一职责：只处理登录相关的业务逻辑
class LoginUseCase {
  /// 认证仓库依赖
  ///
  /// 通过依赖注入获取，遵循依赖倒置原则
  final AuthRepository _authRepository;

  /// 构造函数
  ///
  /// 接收认证仓库的实例
  const LoginUseCase(this._authRepository);

  /// 执行登录操作
  ///
  /// 这是用例的主要方法，包含完整的登录业务流程
  ///
  /// 参数：
  /// - [credential] 登录凭证
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(LoginResult) 包含用户信息和额外数据
  /// - 失败：返回 Result.failure(Failure) 包含具体的失败原因
  ///
  /// 业务流程：
  /// 1. 验证输入参数的有效性
  /// 2. 检查凭证格式是否正确
  /// 3. 验证密码强度
  /// 4. 调用仓库执行登录
  /// 5. 处理登录结果
  /// 6. 记录登录日志
  Future<Result<LoginResult>> execute(LoginCredential credential) async {
    try {
      // 第一步：验证输入参数
      final validationResult = _validateInput(credential);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.failure!);
      }

      // 第二步：验证凭证格式
      if (!credential.isValidFormat) {
        return Result.failure(
          ValidationFailure(_getInvalidFormatMessage(credential.type)),
        );
      }

      // 第三步：验证密码强度
      if (!credential.isPasswordStrong) {
        return Result.failure(const ValidationFailure('密码必须包含字母和数字，且长度至少6位'));
      }

      // 第四步：执行登录
      final loginResult = await _authRepository.login(credential);

      if (loginResult.isFailure) {
        // 登录失败，返回具体的失败信息
        return Result.failure(loginResult.failure!);
      }

      // 第五步：登录成功，构建结果
      final user = loginResult.data!;
      final result = LoginResult(
        user: user,
        isFirstLogin: user.isNewUser,
        requiresPasswordChange: _shouldRequirePasswordChange(user),
        welcomeMessage: _getWelcomeMessage(user),
      );

      // 第六步：记录登录成功日志
      _logLoginSuccess(user, credential.type);

      return Result.success(result);
    } catch (e) {
      // 捕获未预期的异常，转换为通用失败
      return Result.failure(ServerFailure('登录过程中发生未知错误：${e.toString()}'));
    }
  }

  /// 验证输入参数
  ///
  /// 检查登录凭证的基本有效性
  Result<void> _validateInput(LoginCredential credential) {
    // 检查凭证是否为空
    if (credential.credential.trim().isEmpty) {
      return Result.failure(const ValidationFailure('请输入登录凭证'));
    }

    // 检查密码是否为空
    if (credential.password.trim().isEmpty) {
      return Result.failure(const ValidationFailure('请输入密码'));
    }

    // 手机号登录需要检查国家代码
    if (credential.type == LoginType.phone &&
        (credential.countryCode == null || credential.countryCode!.isEmpty)) {
      return Result.failure(const ValidationFailure('请选择国家代码'));
    }

    return Result.success(null);
  }

  /// 获取无效格式的错误消息
  ///
  /// 根据登录类型返回相应的错误提示
  String _getInvalidFormatMessage(LoginType type) {
    switch (type) {
      case LoginType.email:
        return '请输入有效的邮箱地址';
      case LoginType.username:
        return '用户名只能包含字母、数字和下划线，长度3-20位';
      case LoginType.phone:
        return '请输入有效的手机号码';
    }
  }

  /// 检查是否需要强制修改密码
  ///
  /// 业务规则：长时间未登录的用户需要修改密码
  bool _shouldRequirePasswordChange(User user) {
    return user.isInactiveUser;
  }

  /// 生成欢迎消息
  ///
  /// 根据用户状态生成个性化的欢迎消息
  String _getWelcomeMessage(User user) {
    if (user.isNewUser) {
      return '欢迎加入，${user.displayName}！';
    } else if (user.isInactiveUser) {
      return '欢迎回来，${user.displayName}！好久不见了。';
    } else {
      return '欢迎回来，${user.displayName}！';
    }
  }

  /// 记录登录成功日志
  ///
  /// 记录用户登录信息，用于审计和分析
  void _logLoginSuccess(User user, LoginType loginType) {
    // 在实际项目中，这里会调用日志服务
    // 例如：_loggerService.info('User ${user.id} logged in via ${loginType.name}');
    print('用户登录成功: ${user.id} (${loginType.displayName})');
  }
}

/// 登录结果类
///
/// 封装登录成功后的所有相关信息
class LoginResult {
  /// 用户信息
  final User user;

  /// 是否是首次登录
  final bool isFirstLogin;

  /// 是否需要修改密码
  final bool requiresPasswordChange;

  /// 欢迎消息
  final String welcomeMessage;

  /// 构造函数
  const LoginResult({
    required this.user,
    required this.isFirstLogin,
    required this.requiresPasswordChange,
    required this.welcomeMessage,
  });

  /// 对象相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResult &&
        other.user == user &&
        other.isFirstLogin == isFirstLogin &&
        other.requiresPasswordChange == requiresPasswordChange &&
        other.welcomeMessage == welcomeMessage;
  }

  /// 哈希码
  @override
  int get hashCode {
    return Object.hash(
      user,
      isFirstLogin,
      requiresPasswordChange,
      welcomeMessage,
    );
  }

  /// 字符串表示
  @override
  String toString() {
    return 'LoginResult('
        'user: $user, '
        'isFirstLogin: $isFirstLogin, '
        'requiresPasswordChange: $requiresPasswordChange, '
        'welcomeMessage: $welcomeMessage)';
  }
}
