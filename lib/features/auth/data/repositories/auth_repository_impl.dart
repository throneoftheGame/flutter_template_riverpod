import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/login_credential.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/login_request_model.dart';

/// 认证仓库实现
///
/// 实现领域层定义的 AuthRepository 接口
/// 特点：
/// 1. 协调远程数据源和本地数据源
/// 2. 实现缓存策略和离线支持
/// 3. 异常处理和错误转换
/// 4. 数据一致性保证
///
/// 数据流向：
/// UI → UseCase → Repository → DataSource → API/Cache
class AuthRepositoryImpl implements AuthRepository {
  /// 远程数据源依赖
  ///
  /// 负责与后端 API 进行网络通信
  final AuthRemoteDataSource _remoteDataSource;

  /// 本地数据源依赖
  ///
  /// 负责本地数据存储和缓存
  final AuthLocalDataSource _localDataSource;

  /// 构造函数
  ///
  /// 接收远程和本地数据源实例，遵循依赖注入原则
  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<User>> login(LoginCredential credential) async {
    try {
      // 第一步：创建登录请求模型
      final request = LoginRequestModel.fromCredential(
        credential,
        deviceId: await _getDeviceId(),
        clientVersion: await _getClientVersion(),
      );

      // 第二步：调用远程数据源执行登录
      final userModel = await _remoteDataSource.login(request);

      // 第三步：缓存用户数据到本地
      await _localDataSource.cacheUser(userModel);

      // 第四步：更新最后登录时间
      await _localDataSource.updateLastLoginTime();

      // 第五步：转换为领域实体并返回
      final user = userModel.toEntity();
      return Result.success(user);
    } on ValidationException catch (e) {
      // 验证异常：数据格式错误等
      return Result.failure(ValidationFailure(e.message));
    } on AuthException catch (e) {
      // 认证异常：用户名密码错误、账号被锁定等
      return Result.failure(AuthFailure(e.message));
    } on NetworkException catch (e) {
      // 网络异常：连接超时、无网络等
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      // 服务器异常：500错误、服务不可用等
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      // 未知异常
      return Result.failure(ServerFailure('登录过程中发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 调用远程数据源执行注册
      final userModel = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );

      // 注册成功后自动缓存用户数据
      await _localDataSource.cacheUser(userModel);
      await _localDataSource.updateLastLoginTime();

      // 转换为领域实体并返回
      final user = userModel.toEntity();
      return Result.success(user);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('注册过程中发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      // 第一步：通知远程服务器登出（即使失败也要清除本地数据）
      try {
        await _remoteDataSource.logout();
      } catch (e) {
        // 忽略远程登出失败，确保本地清理能够执行
        print('远程登出失败，但将继续清除本地数据: $e');
      }

      // 第二步：清除本地所有认证数据
      await _localDataSource.clearAuthData();

      return Result.success(null);
    } catch (e) {
      // 即使发生异常，也尝试清除本地数据
      try {
        await _localDataSource.clearAuthData();
      } catch (clearError) {
        print('清除本地数据时发生错误: $clearError');
      }

      return Result.failure(ServerFailure('登出过程中发生错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<String>> refreshToken() async {
    try {
      // 获取本地存储的刷新令牌
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return Result.failure(const AuthFailure('刷新令牌不存在，请重新登录'));
      }

      // 调用远程数据源刷新令牌
      final newAccessToken = await _remoteDataSource.refreshToken(refreshToken);

      return Result.success(newAccessToken);
    } on AuthException catch (e) {
      // 刷新令牌失效，清除本地认证数据
      await _localDataSource.clearAuthData();
      return Result.failure(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('刷新令牌时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('发送重置邮件时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return Result.success(null);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('重置密码时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      // 第一步：尝试从本地缓存获取用户数据
      try {
        final cachedUser = await _localDataSource.getCachedUser();
        print('从本地缓存获取用户数据');
        return Result.success(cachedUser.toEntity());
      } on CacheException {
        // 缓存不存在或已过期，从远程获取
        print('本地缓存不可用，从服务器获取用户数据');
      }

      // 第二步：从远程服务器获取最新用户数据
      final userModel = await _remoteDataSource.getCurrentUser();

      // 第三步：更新本地缓存
      await _localDataSource.cacheUser(userModel);

      // 第四步：转换为领域实体并返回
      final user = userModel.toEntity();
      return Result.success(user);
    } on AuthException catch (e) {
      // 认证失败，清除本地数据
      await _localDataSource.clearAuthData();
      return Result.failure(AuthFailure(e.message));
    } on NetworkException catch (e) {
      // 网络异常，尝试返回缓存数据
      try {
        final cachedUser = await _localDataSource.getCachedUser();
        print('网络不可用，返回缓存的用户数据');
        return Result.success(cachedUser.toEntity());
      } on CacheException {
        return Result.failure(NetworkFailure(e.message));
      }
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('获取用户信息时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> updateUserProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      // 调用远程数据源更新用户信息
      final userModel = await _remoteDataSource.updateUserProfile(
        name: name,
        avatarUrl: avatarUrl,
      );

      // 更新本地缓存
      await _localDataSource.cacheUser(userModel);

      // 转换为领域实体并返回
      final user = userModel.toEntity();
      return Result.success(user);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('更新用户信息时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Result.success(null);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('修改密码时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _remoteDataSource.sendEmailVerification();
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('发送验证邮件时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  bool isLoggedIn() {
    try {
      // 这是同步方法，只能检查基本状态
      // 实际的令牌有效性检查需要异步方法
      // 使用同步方式检查本地存储的登录状志，避免类型转换错误
      return _localDataSource.isLoggedInSync();
    } catch (e) {
      print('检查登录状态时发生错误: $e');
      return false;
    }
  }

  @override
  String? getAccessToken() {
    try {
      // 这是同步方法，使用同步版本避免类型转换错误
      return _localDataSource.getAccessTokenSync();
    } catch (e) {
      print('获取访问令牌时发生错误: $e');
      return null;
    }
  }

  /// 获取设备 ID
  ///
  /// 在实际项目中，这里会调用设备信息服务
  Future<String> _getDeviceId() async {
    // TODO: 实现设备 ID 获取逻辑
    // 例如：return await _deviceInfoService.getDeviceId();
    return 'mock_device_id_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取客户端版本
  ///
  /// 在实际项目中，这里会从包信息中获取版本号
  Future<String> _getClientVersion() async {
    // TODO: 实现版本号获取逻辑
    // 例如：return await _packageInfoService.getVersion();
    return '1.0.0';
  }
}
