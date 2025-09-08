import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/login_credential.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

/// 认证状态枚举
///
/// 定义用户的认证状态
enum AuthStatus {
  /// 初始状态，应用启动时的状态
  initial,

  /// 正在检查认证状态
  checking,

  /// 已认证（已登录）
  authenticated,

  /// 未认证（未登录）
  unauthenticated,

  /// 正在登录
  loggingIn,

  /// 正在注册
  registering,

  /// 正在登出
  loggingOut,
}

/// 认证状态数据类
///
/// 封装认证相关的所有状态信息
class AuthState {
  /// 认证状态
  final AuthStatus status;

  /// 当前用户信息（已登录时不为空）
  final User? user;

  /// 错误信息（操作失败时不为空）
  final String? error;

  /// 是否正在加载
  final bool isLoading;

  /// 构造函数
  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.isLoading = false,
  });

  /// 初始状态
  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      error = null,
      isLoading = false;

  /// 复制状态并修改某些属性
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// 便利方法：检查是否已认证
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// 便利方法：检查是否有错误
  bool get hasError => error != null && error!.isNotEmpty;

  /// 便利方法：检查是否正在执行操作
  bool get isBusy =>
      status == AuthStatus.loggingIn ||
      status == AuthStatus.registering ||
      status == AuthStatus.loggingOut ||
      status == AuthStatus.checking;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.error == error &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return Object.hash(status, user, error, isLoading);
  }

  @override
  String toString() {
    return 'AuthState('
        'status: $status, '
        'user: ${user?.email ?? 'null'}, '
        'error: $error, '
        'isLoading: $isLoading)';
  }
}

/// 认证状态通知器
///
/// 管理用户认证状态的业务逻辑
/// 特点：
/// 1. 使用 Clean Architecture 的用例进行业务操作
/// 2. 统一的错误处理和状态管理
/// 3. 自动状态同步和缓存管理
class AuthNotifier extends StateNotifier<AuthState> {
  /// 登录用例依赖
  final LoginUseCase _loginUseCase;

  /// 认证仓库依赖
  final AuthRepository _authRepository;

  /// 构造函数
  AuthNotifier(this._loginUseCase, this._authRepository)
    : super(const AuthState.initial()) {
    // 初始化时检查认证状态
    _checkAuthStatus();
  }

  /// 检查当前认证状态
  ///
  /// 应用启动时调用，检查用户是否已登录
  ///
  /// 业务逻辑：
  /// 1. 首先检查本地存储是否有登录标记
  /// 2. 如果有登录标记，尝试从服务器获取最新用户信息
  /// 3. 如果服务器验证成功，更新为已认证状态
  /// 4. 如果服务器验证失败（如令牌过期），清除本地状态
  /// 5. 如果网络不可用，可以考虑使用缓存的用户信息
  ///
  /// 状态流转：
  /// initial -> checking -> authenticated/unauthenticated
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.checking, clearError: true);

    try {
      // 第一步：检查本地是否有有效的登录状态
      // 这是一个快速的同步检查，只验证本地存储的基本标记
      final isLoggedIn = _authRepository.isLoggedIn();

      if (isLoggedIn) {
        // 第二步：尝试获取用户信息
        // 这会验证令牌的有效性并获取最新的用户数据
        final result = await _authRepository.getCurrentUser();

        if (result.isSuccess) {
          // 认证成功，用户信息有效
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: result.data,
            clearError: true,
          );
        } else {
          // 获取用户信息失败，可能的原因：
          // - 访问令牌已过期
          // - 用户账号被禁用
          // - 网络连接问题
          // - 服务器错误
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
            clearError: true,
          );
        }
      } else {
        // 本地没有登录标记，用户未登录
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
        );
      }
    } catch (e) {
      // 检查过程中发生异常，为了安全起见设置为未认证状态
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: '检查认证状态失败: ${e.toString()}',
        clearUser: true,
      );
    }
  }

  /// 用户登录
  ///
  /// 使用登录凭证进行用户认证
  ///
  /// 参数：
  /// - [credential] 登录凭证，包含用户名/邮箱/手机号和密码
  ///
  /// 返回值：
  /// - bool: 登录是否成功
  ///
  /// 业务流程：
  /// 1. 设置登录中状态，显示加载指示器
  /// 2. 调用登录用例执行完整的登录业务逻辑
  /// 3. 根据登录结果更新认证状态
  /// 4. 处理特殊情况（如强制修改密码）
  /// 5. 返回操作结果供 UI 层处理
  ///
  /// 状态流转：
  /// current -> loggingIn -> authenticated/unauthenticated
  ///
  /// 错误处理：
  /// - 网络错误：显示网络相关提示
  /// - 认证错误：显示用户名密码错误等信息
  /// - 服务器错误：显示服务器不可用提示
  /// - 验证错误：显示输入格式错误信息
  Future<bool> login(LoginCredential credential) async {
    // 第一步：设置登录中状态
    // UI 会根据此状态显示加载指示器，禁用登录按钮
    state = state.copyWith(status: AuthStatus.loggingIn, clearError: true);

    try {
      // 第二步：调用登录用例
      // 用例会处理输入验证、格式检查、密码强度验证等业务逻辑
      final result = await _loginUseCase.execute(credential);

      if (result.isSuccess) {
        // 第三步：登录成功处理
        final loginResult = result.data!;

        // 更新状态为已认证，存储用户信息
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: loginResult.user,
          clearError: true,
        );

        // 第四步：处理特殊业务情况
        if (loginResult.requiresPasswordChange) {
          // 用户长时间未登录，需要强制修改密码
          // 可以导航到修改密码页面或显示相应提示
          _handlePasswordChangeRequired();
        }

        // 可以在这里添加其他登录后的业务逻辑：
        // - 记录登录日志
        // - 同步用户设置
        // - 检查应用更新
        // - 预加载用户数据

        return true;
      } else {
        // 第五步：登录失败处理
        final errorMessage = _getErrorMessage(result.failure!);
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: errorMessage,
          clearUser: true,
        );
        return false;
      }
    } catch (e) {
      // 第六步：异常处理
      // 捕获未预期的异常，确保应用不会崩溃
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: '登录过程中发生未知错误: ${e.toString()}',
        clearUser: true,
      );
      return false;
    }
  }

  /// 用户注册
  ///
  /// 注册新用户账号
  ///
  /// 参数：
  /// - [email] 邮箱地址
  /// - [password] 密码
  /// - [name] 用户姓名
  ///
  /// 返回值：
  /// - bool: 注册是否成功
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // 设置注册中状态
    state = state.copyWith(status: AuthStatus.registering, clearError: true);

    try {
      // 调用注册接口
      final result = await _authRepository.register(
        email: email,
        password: password,
        name: name,
      );

      if (result.isSuccess) {
        // 注册成功，自动登录
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data!,
          clearError: true,
        );
        return true;
      } else {
        // 注册失败
        final errorMessage = _getErrorMessage(result.failure!);
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: errorMessage,
          clearUser: true,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: '注册过程中发生未知错误: ${e.toString()}',
        clearUser: true,
      );
      return false;
    }
  }

  /// 用户登出
  ///
  /// 清除用户认证状态
  ///
  /// 返回值：
  /// - bool: 登出是否成功
  Future<bool> logout() async {
    // 设置登出中状态
    state = state.copyWith(status: AuthStatus.loggingOut, clearError: true);

    try {
      // 调用登出接口
      final result = await _authRepository.logout();

      // 无论成功失败都清除本地状态
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
      );

      return result.isSuccess;
    } catch (e) {
      // 即使发生异常也要清除本地状态
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        error: '登出时发生错误: ${e.toString()}',
      );
      return false;
    }
  }

  /// 刷新用户信息
  ///
  /// 从服务器获取最新的用户信息
  Future<void> refreshUser() async {
    if (state.status != AuthStatus.authenticated) {
      return;
    }

    try {
      final result = await _authRepository.getCurrentUser();

      if (result.isSuccess) {
        state = state.copyWith(user: result.data, clearError: true);
      } else {
        // 获取用户信息失败，可能需要重新登录
        if (result.failure is AuthFailure) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
            error: '登录状态已过期，请重新登录',
          );
        }
      }
    } catch (e) {
      // 刷新失败，但不改变认证状态
      state = state.copyWith(error: '刷新用户信息失败: ${e.toString()}');
    }
  }

  /// 清除错误信息
  ///
  /// 清除当前的错误状态
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// 处理需要修改密码的情况
  ///
  /// 当用户需要强制修改密码时调用
  void _handlePasswordChangeRequired() {
    // 在实际项目中，这里可能会导航到修改密码页面
    // 或者显示相应的提示
    print('用户需要修改密码');
  }

  /// 获取用户友好的错误消息
  ///
  /// 将技术性的失败信息转换为用户可理解的错误消息
  String _getErrorMessage(Failure failure) {
    if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return '网络连接失败，请检查网络设置';
    } else if (failure is ServerFailure) {
      return '服务器暂时不可用，请稍后重试';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return '操作失败，请重试';
    }
  }
}

/// 依赖注入提供者
///
/// 使用 Riverpod 进行依赖注入和状态管理

// 注意：以下提供者在实际项目中需要根据具体的依赖注入配置进行调整

/// 认证仓库提供者
///
/// 提供 AuthRepository 的实例
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // 在实际项目中，这里需要注入真实的依赖
  throw UnimplementedError('AuthRepository provider needs implementation');

  // 示例实现：
  // final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  // final localDataSource = ref.read(authLocalDataSourceProvider);
  // return AuthRepositoryImpl(remoteDataSource, localDataSource);
});

/// 登录用例提供者
///
/// 提供 LoginUseCase 的实例
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// 认证状态提供者
///
/// 提供全局的认证状态管理
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(loginUseCase, repository);
});

/// 当前用户提供者
///
/// 提供当前登录用户的信息
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// 认证状态提供者
///
/// 提供当前的认证状态
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status;
});

/// 是否已认证提供者
///
/// 提供用户是否已认证的布尔值
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});
