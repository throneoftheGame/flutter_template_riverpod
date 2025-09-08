import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// 认证本地数据源
///
/// 负责认证相关数据的本地存储和读取
/// 特点：
/// 1. 使用 SharedPreferences 进行持久化存储
/// 2. 缓存用户信息，减少网络请求
/// 3. 存储认证令牌和会话信息
/// 4. 提供数据加密和安全存储
abstract class AuthLocalDataSource {
  /// 缓存用户信息
  ///
  /// 将用户数据保存到本地，用于离线访问和快速加载
  ///
  /// 参数：
  /// - [user] 要缓存的用户模型
  Future<void> cacheUser(UserModel user);

  /// 获取缓存的用户信息
  ///
  /// 从本地存储读取用户数据
  ///
  /// 返回值：
  /// - UserModel: 缓存的用户信息
  ///
  /// 异常：
  /// - CacheException: 缓存数据不存在或已损坏
  Future<UserModel> getCachedUser();

  /// 清除用户缓存
  ///
  /// 删除本地存储的用户数据
  Future<void> clearUserCache();

  /// 存储访问令牌
  ///
  /// 安全地存储用户的访问令牌
  ///
  /// 参数：
  /// - [token] 访问令牌
  /// - [expiresAt] 令牌过期时间（可选）
  Future<void> storeAccessToken(String token, [DateTime? expiresAt]);

  /// 获取访问令牌
  ///
  /// 从本地存储读取访问令牌
  ///
  /// 返回值：
  /// - String?: 访问令牌，如果不存在或已过期则返回 null
  Future<String?> getAccessToken();

  /// 存储刷新令牌
  ///
  /// 安全地存储用户的刷新令牌
  ///
  /// 参数：
  /// - [token] 刷新令牌
  Future<void> storeRefreshToken(String token);

  /// 获取刷新令牌
  ///
  /// 从本地存储读取刷新令牌
  ///
  /// 返回值：
  /// - String?: 刷新令牌，如果不存在则返回 null
  Future<String?> getRefreshToken();

  /// 清除所有认证数据
  ///
  /// 删除所有本地存储的认证相关数据
  Future<void> clearAuthData();

  /// 检查用户是否已登录
  ///
  /// 检查本地是否存储了有效的认证令牌
  ///
  /// 返回值：
  /// - bool: true 表示已登录，false 表示未登录
  Future<bool> isLoggedIn();

  /// 同步检查用户是否已登录
  ///
  /// 同步版本的登录状态检查，用于满足领域层的同步接口要求
  ///
  /// 返回值：
  /// - bool: true 表示已登录，false 表示未登录
  ///
  /// 注意：这个方法只检查基本状态，不会验证令牌是否过期
  bool isLoggedInSync();

  /// 同步获取访问令牌
  ///
  /// 同步版本的令牌获取方法，用于满足领域层的同步接口要求
  ///
  /// 返回值：
  /// - String?: 访问令牌，如果不存在则返回 null
  ///
  /// 注意：这个方法不会检查令牌是否过期
  String? getAccessTokenSync();

  /// 获取最后登录时间
  ///
  /// 获取用户上次登录的时间戳
  ///
  /// 返回值：
  /// - DateTime?: 最后登录时间，如果从未登录则返回 null
  Future<DateTime?> getLastLoginTime();

  /// 更新最后登录时间
  ///
  /// 记录用户的登录时间
  Future<void> updateLastLoginTime();
}

/// 认证本地数据源实现
///
/// AuthLocalDataSource 的具体实现
/// 使用 SharedPreferences 进行数据持久化
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// SharedPreferences 实例
  ///
  /// 用于数据的持久化存储
  final SharedPreferences _prefs;

  /// 构造函数
  ///
  /// 接收 SharedPreferences 实例
  const AuthLocalDataSourceImpl(this._prefs);

  /// 存储键常量
  ///
  /// 定义所有本地存储使用的键名，确保一致性
  static const String _userKey = 'cached_user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _lastLoginKey = 'last_login_time';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      // 验证用户数据有效性
      if (!user.isValid) {
        throw const ValidationException('用户数据无效，无法缓存');
      }

      // 将用户模型转换为 JSON 字符串并存储
      final userJson = user.toJson();
      final jsonString = _encodeJson(userJson);

      final success = await _prefs.setString(_userKey, jsonString);
      if (!success) {
        throw const CacheException('用户数据缓存失败');
      }

      // 记录缓存时间（用于缓存过期检查）
      await _prefs.setInt(
        '${_userKey}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      print('用户数据已缓存: ${user.email}');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw CacheException('缓存用户数据时发生错误: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      // 检查缓存是否存在
      final jsonString = _prefs.getString(_userKey);
      if (jsonString == null || jsonString.isEmpty) {
        throw const CacheException('未找到缓存的用户数据');
      }

      // 检查缓存是否过期（24小时过期）
      final timestamp = _prefs.getInt('${_userKey}_timestamp');
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        final difference = now.difference(cacheTime);

        if (difference.inHours > 24) {
          // 缓存已过期，清除并抛出异常
          await clearUserCache();
          throw const CacheException('缓存的用户数据已过期');
        }
      }

      // 解析 JSON 数据
      final userJson = _decodeJson(jsonString);
      final user = UserModel.fromJson(userJson);

      // 验证解析后的数据
      if (!user.isValid) {
        throw const CacheException('缓存的用户数据已损坏');
      }

      print('从缓存加载用户数据: ${user.email}');
      return user;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw CacheException('读取缓存用户数据时发生错误: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _prefs.remove(_userKey);
      await _prefs.remove('${_userKey}_timestamp');
      print('用户缓存已清除');
    } catch (e) {
      throw CacheException('清除用户缓存时发生错误: ${e.toString()}');
    }
  }

  @override
  Future<void> storeAccessToken(String token, [DateTime? expiresAt]) async {
    try {
      // 验证令牌有效性
      if (token.isEmpty) {
        throw const ValidationException('访问令牌不能为空');
      }

      // 存储访问令牌
      final success = await _prefs.setString(_accessTokenKey, token);
      if (!success) {
        throw const CacheException('访问令牌存储失败');
      }

      // 存储过期时间
      if (expiresAt != null) {
        await _prefs.setInt(_tokenExpiryKey, expiresAt.millisecondsSinceEpoch);
      }

      print('访问令牌已存储，过期时间: $expiresAt');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw CacheException('存储访问令牌时发生错误: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = _prefs.getString(_accessTokenKey);
      if (token == null || token.isEmpty) {
        return null;
      }

      // 检查令牌是否过期
      final expiryTimestamp = _prefs.getInt(_tokenExpiryKey);
      if (expiryTimestamp != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (DateTime.now().isAfter(expiryTime)) {
          // 令牌已过期，清除并返回 null
          await _prefs.remove(_accessTokenKey);
          await _prefs.remove(_tokenExpiryKey);
          print('访问令牌已过期并被清除');
          return null;
        }
      }

      return token;
    } catch (e) {
      print('获取访问令牌时发生错误: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<void> storeRefreshToken(String token) async {
    try {
      if (token.isEmpty) {
        throw const ValidationException('刷新令牌不能为空');
      }

      final success = await _prefs.setString(_refreshTokenKey, token);
      if (!success) {
        throw const CacheException('刷新令牌存储失败');
      }

      print('刷新令牌已存储');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw CacheException('存储刷新令牌时发生错误: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return _prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('获取刷新令牌时发生错误: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      // 清除所有认证相关数据
      final keys = [
        _userKey,
        '${_userKey}_timestamp',
        _accessTokenKey,
        _refreshTokenKey,
        _tokenExpiryKey,
        _lastLoginKey,
        _isLoggedInKey,
      ];

      for (final key in keys) {
        await _prefs.remove(key);
      }

      print('所有认证数据已清除');
    } catch (e) {
      throw CacheException('清除认证数据时发生错误: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      // 检查登录状态标志
      final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) {
        return false;
      }

      // 检查是否有有效的访问令牌
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        // 令牌不存在或已过期，更新登录状态
        await _prefs.setBool(_isLoggedInKey, false);
        return false;
      }

      return true;
    } catch (e) {
      print('检查登录状态时发生错误: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<DateTime?> getLastLoginTime() async {
    try {
      final timestamp = _prefs.getInt(_lastLoginKey);
      if (timestamp == null) {
        return null;
      }
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      print('获取最后登录时间时发生错误: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<void> updateLastLoginTime() async {
    try {
      final now = DateTime.now();
      await _prefs.setInt(_lastLoginKey, now.millisecondsSinceEpoch);
      await _prefs.setBool(_isLoggedInKey, true);
      print('最后登录时间已更新: $now');
    } catch (e) {
      print('更新最后登录时间时发生错误: ${e.toString()}');
    }
  }

  @override
  bool isLoggedInSync() {
    try {
      // 检查登录状态标志
      final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) {
        return false;
      }

      // 检查是否有访问令牌（不检查过期时间，因为这是同步方法）
      final accessToken = _prefs.getString(_accessTokenKey);
      return accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      print('同步检查登录状态时发生错误: ${e.toString()}');
      return false;
    }
  }

  @override
  String? getAccessTokenSync() {
    try {
      final token = _prefs.getString(_accessTokenKey);
      if (token == null || token.isEmpty) {
        return null;
      }

      // 注意：同步方法不检查令牌过期时间，只返回存储的令牌
      // 如果需要检查过期时间，请使用异步版本 getAccessToken()
      return token;
    } catch (e) {
      print('同步获取访问令牌时发生错误: ${e.toString()}');
      return null;
    }
  }

  /// JSON 编码
  ///
  /// 将 Map 转换为 JSON 字符串
  /// 在实际项目中，这里可以添加加密逻辑
  ///
  /// 安全考虑：
  /// - 敏感数据应该加密存储
  /// - 可以使用 AES 或其他对称加密算法
  /// - 密钥可以存储在 Android Keystore 或 iOS Keychain 中
  String _encodeJson(Map<String, dynamic> data) {
    // TODO: 在实际项目中添加加密逻辑
    // 示例实现：
    // final jsonString = jsonEncode(data);
    // return _encryptionService.encrypt(jsonString);

    // 当前简化实现（仅用于演示）
    return data.toString();
  }

  /// JSON 解码
  ///
  /// 将 JSON 字符串转换为 Map
  /// 在实际项目中，这里可以添加解密逻辑
  ///
  /// 安全考虑：
  /// - 解密失败时应该清除相关缓存
  /// - 需要处理密钥轮换的情况
  /// - 应该验证数据完整性
  Map<String, dynamic> _decodeJson(String jsonString) {
    // TODO: 在实际项目中添加解密逻辑
    // 示例实现：
    // try {
    //   final decrypted = _encryptionService.decrypt(jsonString);
    //   return jsonDecode(decrypted) as Map<String, dynamic>;
    // } catch (e) {
    //   throw CacheException('数据解密失败: ${e.toString()}');
    // }

    // 当前简化实现（仅用于演示）
    throw const CacheException('JSON 解码功能需要完整实现，请在实际项目中实现加密解密逻辑');
  }
}
