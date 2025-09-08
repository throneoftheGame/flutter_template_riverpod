import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

/// 认证远程数据源
///
/// 负责与后端 API 进行认证相关的网络通信
/// 特点：
/// 1. 封装所有认证相关的 HTTP 请求
/// 2. 处理网络异常和错误响应
/// 3. 数据格式转换（JSON ↔ Model）
/// 4. 统一的错误处理机制
abstract class AuthRemoteDataSource {
  /// 用户登录
  ///
  /// 向服务器发送登录请求
  ///
  /// 参数：
  /// - [request] 登录请求模型
  ///
  /// 返回值：
  /// - UserModel: 登录成功的用户信息
  ///
  /// 异常：
  /// - ServerException: 服务器错误
  /// - NetworkException: 网络连接错误
  /// - AuthException: 认证失败
  Future<UserModel> login(LoginRequestModel request);

  /// 用户注册
  ///
  /// 向服务器发送注册请求
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  });

  /// 刷新令牌
  ///
  /// 使用刷新令牌获取新的访问令牌
  Future<String> refreshToken(String refreshToken);

  /// 用户登出
  ///
  /// 通知服务器用户登出（清除服务端会话）
  Future<void> logout();

  /// 忘记密码
  ///
  /// 发送密码重置邮件
  Future<void> forgotPassword(String email);

  /// 重置密码
  ///
  /// 使用重置令牌设置新密码
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  /// 获取用户信息
  ///
  /// 从服务器获取当前用户的最新信息
  Future<UserModel> getCurrentUser();

  /// 更新用户信息
  ///
  /// 更新用户的个人资料
  Future<UserModel> updateUserProfile({String? name, String? avatarUrl});

  /// 修改密码
  ///
  /// 用户主动修改密码
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// 发送邮箱验证
  ///
  /// 发送邮箱验证链接
  Future<void> sendEmailVerification();
}

/// 认证远程数据源实现
///
/// AuthRemoteDataSource 的具体实现
/// 使用 Dio 进行 HTTP 网络请求
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Dio 客户端依赖
  ///
  /// 用于执行 HTTP 请求，已配置好拦截器和基础设置
  final DioClient _dioClient;

  /// 构造函数
  ///
  /// 接收 DioClient 实例，遵循依赖注入原则
  const AuthRemoteDataSourceImpl(this._dioClient);

  /// API 端点常量
  static const String _loginEndpoint = '/auth/login';
  static const String _registerEndpoint = '/auth/register';
  static const String _logoutEndpoint = '/auth/logout';
  static const String _refreshEndpoint = '/auth/refresh';
  static const String _forgotPasswordEndpoint = '/auth/forgot-password';
  static const String _resetPasswordEndpoint = '/auth/reset-password';
  static const String _userEndpoint = '/auth/user';
  static const String _updateProfileEndpoint = '/auth/profile';
  static const String _changePasswordEndpoint = '/auth/change-password';
  static const String _verifyEmailEndpoint = '/auth/verify-email';

  @override
  Future<UserModel> login(LoginRequestModel request) async {
    try {
      // 验证请求数据
      if (!request.isValid) {
        throw const ValidationException('登录请求数据无效');
      }

      // 发送 POST 请求到登录端点
      final response = await _dioClient.post(
        _loginEndpoint,
        data: request.toJson(),
      );

      // 解析响应数据
      final responseModel = LoginResponseModel.fromJson(response.data);

      // 检查业务逻辑成功状态
      if (!responseModel.success) {
        throw AuthException(responseModel.message, responseModel.errorCode);
      }

      // 验证响应数据完整性
      if (!responseModel.isValid) {
        throw const ServerException('服务器返回的数据格式不正确');
      }

      // 存储令牌（在实际项目中，这里会调用令牌存储服务）
      if (responseModel.accessToken != null) {
        await _storeTokens(
          responseModel.accessToken!,
          responseModel.refreshToken,
          responseModel.expiresAt,
        );
      }

      // 创建并返回用户模型
      final userModel = UserModel.fromJson(responseModel.userData!);

      // 验证用户数据有效性
      if (!userModel.isValid) {
        throw const ServerException('用户数据格式不正确');
      }

      return userModel;
    } on DioException catch (e) {
      // 处理 Dio 网络异常
      throw _handleDioException(e);
    } catch (e) {
      // 处理其他异常
      if (e is AppException) {
        rethrow; // 重新抛出应用异常
      }
      throw ServerException('登录请求处理失败: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 构建注册请求数据
      final requestData = {'email': email, 'password': password, 'name': name};

      // 发送注册请求
      final response = await _dioClient.post(
        _registerEndpoint,
        data: requestData,
      );

      // 解析响应并返回用户模型
      final userData = response.data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('注册请求处理失败: ${e.toString()}');
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        _refreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String?;
      final expiresAt = response.data['expires_at'] != null
          ? DateTime.parse(response.data['expires_at'] as String)
          : null;

      // 更新存储的令牌
      await _storeTokens(newAccessToken, newRefreshToken, expiresAt);

      return newAccessToken;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('令牌刷新失败: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // 通知服务器登出（可选，即使失败也要清除本地令牌）
      await _dioClient.post(_logoutEndpoint);
    } on DioException {
      // 忽略网络错误，确保本地清理能够执行
    } finally {
      // 清除本地存储的令牌
      await _clearTokens();
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(_forgotPasswordEndpoint, data: {'email': email});
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('发送重置邮件失败: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dioClient.post(
        _resetPasswordEndpoint,
        data: {'token': token, 'password': newPassword},
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('密码重置失败: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.get(_userEndpoint);
      final userData = response.data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('获取用户信息失败: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserProfile({String? name, String? avatarUrl}) async {
    try {
      final requestData = <String, dynamic>{};
      if (name != null) requestData['name'] = name;
      if (avatarUrl != null) requestData['avatar_url'] = avatarUrl;

      final response = await _dioClient.put(
        _updateProfileEndpoint,
        data: requestData,
      );

      final userData = response.data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('更新用户信息失败: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.put(
        _changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('修改密码失败: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _dioClient.post(_verifyEmailEndpoint);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('发送验证邮件失败: ${e.toString()}');
    }
  }

  /// 处理 Dio 异常
  ///
  /// 将 Dio 的网络异常转换为应用异常
  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('网络连接超时，请检查网络设置');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] as String?;

        if (statusCode == 401) {
          return AuthException(message ?? '认证失败，请重新登录');
        } else if (statusCode == 403) {
          return AuthException(message ?? '权限不足');
        } else if (statusCode == 404) {
          return const ServerException('请求的资源不存在');
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message ?? '服务器内部错误');
        } else {
          return ServerException(message ?? '请求处理失败');
        }

      case DioExceptionType.connectionError:
        return const NetworkException('网络连接失败，请检查网络设置');

      case DioExceptionType.badCertificate:
        return const NetworkException('网络安全证书验证失败');

      case DioExceptionType.cancel:
        return const NetworkException('请求已取消');

      case DioExceptionType.unknown:
        return NetworkException('网络请求失败: ${e.message}');
    }
  }

  /// 存储认证令牌
  ///
  /// 在实际项目中，这里会调用安全存储服务
  Future<void> _storeTokens(
    String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  ) async {
    // TODO: 实现令牌存储逻辑
    // 例如：await _secureStorage.write('access_token', accessToken);
    print('存储访问令牌: ${accessToken.substring(0, 10)}...');
    if (refreshToken != null) {
      print('存储刷新令牌: ${refreshToken.substring(0, 10)}...');
    }
    if (expiresAt != null) {
      print('令牌过期时间: $expiresAt');
    }
  }

  /// 清除认证令牌
  ///
  /// 清除本地存储的所有认证相关数据
  Future<void> _clearTokens() async {
    // TODO: 实现令牌清除逻辑
    // 例如：await _secureStorage.deleteAll();
    print('清除所有认证令牌');
  }
}
