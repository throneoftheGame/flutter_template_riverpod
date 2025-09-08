import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user.dart'; // 添加 User 实体导入
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';
import 'auth_provider.dart';

/// 认证模块依赖注入配置
///
/// 这个文件配置了认证模块的所有依赖关系，实现了完整的依赖注入
/// 特点：
/// 1. 遵循依赖倒置原则，高层模块不依赖低层模块
/// 2. 使用 Riverpod 进行依赖注入和生命周期管理
/// 3. 支持测试时的依赖替换
/// 4. 确保单例模式的正确实现

/// SharedPreferences 提供者
///
/// 提供应用级别的 SharedPreferences 实例
/// 注意：在实际应用中，这应该在应用启动时初始化
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // 在实际项目中，SharedPreferences 需要异步初始化
  // 这里抛出异常提醒开发者需要在 main.dart 中正确初始化
  throw UnimplementedError(
    'SharedPreferences 需要在 main.dart 中异步初始化\n'
    '示例代码：\n'
    'final prefs = await SharedPreferences.getInstance();\n'
    'runApp(ProviderScope(\n'
    '  overrides: [\n'
    '    sharedPreferencesProvider.overrideWithValue(prefs),\n'
    '  ],\n'
    '  child: MyApp(),\n'
    '));',
  );
});

/// DioClient 提供者
///
/// 提供配置好的 HTTP 客户端实例
/// 包含拦截器、超时设置等网络配置
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// 认证远程数据源提供者
///
/// 提供处理网络请求的远程数据源实例
/// 依赖：DioClient
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});

/// 认证本地数据源提供者
///
/// 提供处理本地存储的数据源实例
/// 依赖：SharedPreferences
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(prefs);
});

/// 认证仓库提供者
///
/// 提供认证仓库的具体实现
/// 依赖：AuthRemoteDataSource, AuthLocalDataSource
///
/// 这是数据层的核心，协调远程和本地数据源
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource, localDataSource);
});

/// 登录用例提供者
///
/// 提供登录业务逻辑的用例实现
/// 依赖：AuthRepository
///
/// 这是领域层的核心，封装了完整的登录业务流程
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// 认证状态提供者（重新导出）
///
/// 提供全局的认证状态管理
/// 依赖：LoginUseCase, AuthRepository
///
/// 这是表现层的核心，管理整个应用的认证状态
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(loginUseCase, repository);
});

/// 当前用户提供者（重新导出）
///
/// 提供当前登录用户的信息
/// 这是一个派生状态，从认证状态中提取用户信息
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// 认证状态提供者（重新导出）
///
/// 提供当前的认证状态枚举值
/// 用于 UI 层判断当前的认证状态
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status;
});

/// 是否已认证提供者（重新导出）
///
/// 提供用户是否已认证的布尔值
/// 这是最常用的认证状态判断
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// 认证错误提供者
///
/// 提供当前的认证错误信息
/// 用于 UI 层显示错误提示
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.error;
});

/// 认证加载状态提供者
///
/// 提供认证操作的加载状态
/// 用于 UI 层显示加载指示器
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isBusy;
});

/// 依赖注入初始化帮助类
///
/// 提供便捷的方法来初始化和配置依赖注入
class AuthDependencyInjection {
  /// 获取用于测试的提供者覆盖列表
  ///
  /// 在测试环境中，可以使用 mock 对象替换真实的依赖
  ///
  /// 示例：
  /// ```dart
  /// testWidgets('登录测试', (tester) async {
  ///   await tester.pumpWidget(
  ///     ProviderScope(
  ///       overrides: AuthDependencyInjection.getTestOverrides(
  ///         mockRepository: mockAuthRepository,
  ///         mockPrefs: mockSharedPreferences,
  ///       ),
  ///       child: LoginPage(),
  ///     ),
  ///   );
  /// });
  /// ```
  static List<Override> getTestOverrides({
    AuthRepository? mockRepository,
    SharedPreferences? mockPrefs,
    DioClient? mockDioClient,
  }) {
    final overrides = <Override>[];

    if (mockPrefs != null) {
      overrides.add(sharedPreferencesProvider.overrideWithValue(mockPrefs));
    }

    if (mockDioClient != null) {
      overrides.add(dioClientProvider.overrideWithValue(mockDioClient));
    }

    if (mockRepository != null) {
      overrides.add(authRepositoryProvider.overrideWithValue(mockRepository));
    }

    return overrides;
  }

  /// 验证依赖注入配置是否正确
  ///
  /// 在开发环境中可以调用此方法来检查依赖配置
  ///
  /// 抛出异常如果配置不正确
  static void validateConfiguration(ProviderContainer container) {
    try {
      // 尝试获取关键依赖，验证配置是否正确
      container.read(authRepositoryProvider);
      container.read(loginUseCaseProvider);
      container.read(authProvider);

      print('✅ 认证模块依赖注入配置验证成功');
    } catch (e) {
      print('❌ 认证模块依赖注入配置验证失败: $e');
      rethrow;
    }
  }
}

/// 认证模块提供者集合
///
/// 将所有认证相关的提供者集中管理，便于导入和使用
class AuthProviders {
  // 核心状态提供者
  static final auth = authProvider;
  static final currentUser = currentUserProvider;
  static final authStatus = authStatusProvider;
  static final isAuthenticated = isAuthenticatedProvider;
  static final authError = authErrorProvider;
  static final authLoading = authLoadingProvider;

  // 业务逻辑提供者
  static final loginUseCase = loginUseCaseProvider;
  static final repository = authRepositoryProvider;

  // 数据源提供者
  static final remoteDataSource = authRemoteDataSourceProvider;
  static final localDataSource = authLocalDataSourceProvider;

  // 基础设施提供者
  static final dioClient = dioClientProvider;
  static final sharedPreferences = sharedPreferencesProvider;
}

/// 使用示例：
/// 
/// 在 main.dart 中初始化：
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // 初始化 SharedPreferences
///   final prefs = await SharedPreferences.getInstance();
///   
///   runApp(
///     ProviderScope(
///       overrides: [
///         sharedPreferencesProvider.overrideWithValue(prefs),
///       ],
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
/// 
/// 在 Widget 中使用：
/// ```dart
/// class LoginPage extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authState = ref.watch(AuthProviders.auth);
///     final isLoading = ref.watch(AuthProviders.authLoading);
///     
///     return Scaffold(
///       body: isLoading 
///         ? CircularProgressIndicator()
///         : LoginForm(),
///     );
///   }
/// }
/// ```
