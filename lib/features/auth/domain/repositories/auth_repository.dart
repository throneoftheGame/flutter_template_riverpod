import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../entities/login_credential.dart';

/// 认证仓库接口
///
/// 这是领域层定义的抽象接口，描述了认证相关的所有操作
/// 特点：
/// 1. 只定义接口，不包含具体实现
/// 2. 使用 Result 类型包装返回值，统一处理成功和失败情况
/// 3. 所有方法都是异步的，因为涉及网络请求或数据库操作
/// 4. 数据层会实现这个接口，提供具体的业务逻辑
abstract class AuthRepository {
  /// 用户登录
  ///
  /// 参数：
  /// - [credential] 登录凭证，包含用户名/邮箱/手机号和密码
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(User) 包含用户信息
  /// - 失败：返回 Result.failure(Failure) 包含错误信息
  ///
  /// 可能的失败情况：
  /// - 网络连接失败
  /// - 用户名/密码错误
  /// - 账号被锁定
  /// - 服务器错误
  Future<Result<User>> login(LoginCredential credential);

  /// 用户注册
  ///
  /// 参数：
  /// - [email] 用户邮箱
  /// - [password] 用户密码
  /// - [name] 用户姓名
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(User) 包含新注册的用户信息
  /// - 失败：返回 Result.failure(Failure) 包含错误信息
  ///
  /// 可能的失败情况：
  /// - 邮箱已被注册
  /// - 密码强度不够
  /// - 网络连接失败
  /// - 服务器错误
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
  });

  /// 用户登出
  ///
  /// 清除本地存储的用户信息和认证令牌
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(void)
  /// - 失败：返回 Result.failure(Failure)
  ///
  /// 注意：即使网络请求失败，本地数据也会被清除
  Future<Result<void>> logout();

  /// 刷新认证令牌
  ///
  /// 当访问令牌过期时，使用刷新令牌获取新的访问令牌
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(String) 包含新的访问令牌
  /// - 失败：返回 Result.failure(Failure) 需要重新登录
  Future<Result<String>> refreshToken();

  /// 忘记密码
  ///
  /// 发送密码重置邮件到用户邮箱
  ///
  /// 参数：
  /// - [email] 用户邮箱地址
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(void)
  /// - 失败：返回 Result.failure(Failure)
  ///
  /// 可能的失败情况：
  /// - 邮箱不存在
  /// - 网络连接失败
  /// - 服务器错误
  Future<Result<void>> forgotPassword(String email);

  /// 重置密码
  ///
  /// 使用重置令牌设置新密码
  ///
  /// 参数：
  /// - [token] 密码重置令牌（从邮件链接中获取）
  /// - [newPassword] 新密码
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(void)
  /// - 失败：返回 Result.failure(Failure)
  ///
  /// 可能的失败情况：
  /// - 令牌已过期
  /// - 令牌无效
  /// - 密码强度不够
  /// - 网络连接失败
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// 获取当前用户信息
  ///
  /// 从本地存储或服务器获取当前登录用户的信息
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(User) 包含用户信息
  /// - 失败：返回 Result.failure(Failure) 用户未登录或令牌过期
  Future<Result<User>> getCurrentUser();

  /// 更新用户信息
  ///
  /// 更新当前登录用户的个人信息
  ///
  /// 参数：
  /// - [name] 新的用户姓名（可选）
  /// - [avatarUrl] 新的头像 URL（可选）
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(User) 包含更新后的用户信息
  /// - 失败：返回 Result.failure(Failure)
  Future<Result<User>> updateUserProfile({String? name, String? avatarUrl});

  /// 修改密码
  ///
  /// 用户主动修改密码（需要提供当前密码验证）
  ///
  /// 参数：
  /// - [currentPassword] 当前密码
  /// - [newPassword] 新密码
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(void)
  /// - 失败：返回 Result.failure(Failure)
  ///
  /// 可能的失败情况：
  /// - 当前密码错误
  /// - 新密码强度不够
  /// - 网络连接失败
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// 验证邮箱
  ///
  /// 发送邮箱验证链接到用户邮箱
  ///
  /// 返回值：
  /// - 成功：返回 Result.success(void)
  /// - 失败：返回 Result.failure(Failure)
  Future<Result<void>> sendEmailVerification();

  /// 检查用户是否已登录
  ///
  /// 检查本地是否存储了有效的认证令牌
  ///
  /// 返回值：
  /// - true: 用户已登录
  /// - false: 用户未登录或令牌已过期
  ///
  /// 注意：这是同步方法，只检查本地状态，不进行网络请求
  bool isLoggedIn();

  /// 获取当前访问令牌
  ///
  /// 从本地存储获取当前的访问令牌
  ///
  /// 返回值：
  /// - 有效令牌：返回令牌字符串
  /// - 无令牌或已过期：返回 null
  String? getAccessToken();
}
