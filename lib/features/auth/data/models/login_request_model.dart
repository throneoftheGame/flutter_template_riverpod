import '../../domain/entities/login_credential.dart';

/// 登录请求数据模型
///
/// 用于封装发送到服务器的登录请求数据
/// 特点：
/// 1. 将领域层的登录凭证转换为 API 请求格式
/// 2. 处理不同登录类型的数据格式化
/// 3. 包含请求验证和安全处理
class LoginRequestModel {
  /// 登录凭证（用户名/邮箱/手机号）
  final String credential;

  /// 密码
  final String password;

  /// 登录类型
  final String loginType;

  /// 国家代码（手机号登录时使用）
  final String? countryCode;

  /// 设备信息（用于安全审计）
  final String? deviceId;

  /// 客户端版本
  final String? clientVersion;

  /// 构造函数
  const LoginRequestModel({
    required this.credential,
    required this.password,
    required this.loginType,
    this.countryCode,
    this.deviceId,
    this.clientVersion,
  });

  /// 从登录凭证创建请求模型
  ///
  /// 将领域层的 LoginCredential 转换为 API 请求格式
  ///
  /// 参数：
  /// - [credential] 领域层的登录凭证
  /// - [deviceId] 设备唯一标识符（可选）
  /// - [clientVersion] 客户端版本号（可选）
  ///
  /// 返回值：
  /// - LoginRequestModel 实例
  factory LoginRequestModel.fromCredential(
    LoginCredential credential, {
    String? deviceId,
    String? clientVersion,
  }) {
    return LoginRequestModel(
      credential: credential.credential,
      password: credential.password,
      loginType: _mapLoginType(credential.type),
      countryCode: credential.countryCode,
      deviceId: deviceId,
      clientVersion: clientVersion,
    );
  }

  /// 映射登录类型到 API 格式
  ///
  /// 将领域层的枚举转换为 API 期望的字符串格式
  static String _mapLoginType(LoginType type) {
    switch (type) {
      case LoginType.email:
        return 'email';
      case LoginType.username:
        return 'username';
      case LoginType.phone:
        return 'phone';
    }
  }

  /// 转换为 JSON
  ///
  /// 用于 HTTP 请求的 body 数据
  ///
  /// 返回值：
  /// - JSON 数据 Map
  ///
  /// 注意：
  /// - 密码会在实际项目中进行加密处理
  /// - 包含设备信息用于安全审计
  /// - 过滤空值以减少请求大小
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'credential': credential,
      'password': password, // 实际项目中应该加密
      'login_type': loginType,
    };

    // 添加可选字段
    if (countryCode != null) {
      json['country_code'] = countryCode;
    }

    if (deviceId != null) {
      json['device_id'] = deviceId;
    }

    if (clientVersion != null) {
      json['client_version'] = clientVersion;
    }

    return json;
  }

  /// 获取完整的登录标识符
  ///
  /// 根据登录类型返回完整的标识符
  /// 例如：手机号登录时返回 "+86138xxxx"
  String get fullCredential {
    if (loginType == 'phone' && countryCode != null) {
      return '$countryCode$credential';
    }
    return credential;
  }

  /// 验证请求数据的有效性
  ///
  /// 检查请求数据是否符合 API 要求
  ///
  /// 返回值：
  /// - true: 数据有效
  /// - false: 数据无效
  bool get isValid {
    // 检查必需字段
    if (credential.isEmpty || password.isEmpty || loginType.isEmpty) {
      return false;
    }

    // 手机号登录必须有国家代码
    if (loginType == 'phone' && (countryCode == null || countryCode!.isEmpty)) {
      return false;
    }

    // 检查密码长度
    if (password.length < 6) {
      return false;
    }

    return true;
  }

  /// 获取安全的字符串表示
  ///
  /// 隐藏敏感信息（如密码）的字符串表示
  @override
  String toString() {
    return 'LoginRequestModel('
        'credential: $credential, '
        'loginType: $loginType, '
        'countryCode: $countryCode, '
        'password: [HIDDEN], '
        'deviceId: $deviceId, '
        'clientVersion: $clientVersion)';
  }
}

/// 登录响应数据模型
///
/// 用于解析服务器返回的登录响应数据
class LoginResponseModel {
  /// 是否成功
  final bool success;

  /// 响应消息
  final String message;

  /// 用户数据（成功时返回）
  final Map<String, dynamic>? userData;

  /// 访问令牌
  final String? accessToken;

  /// 刷新令牌
  final String? refreshToken;

  /// 令牌过期时间
  final DateTime? expiresAt;

  /// 错误代码（失败时返回）
  final String? errorCode;

  /// 构造函数
  const LoginResponseModel({
    required this.success,
    required this.message,
    this.userData,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.errorCode,
  });

  /// 从 JSON 创建响应模型
  ///
  /// 解析服务器返回的 JSON 响应
  ///
  /// 参数：
  /// - [json] JSON 响应数据
  ///
  /// 返回值：
  /// - LoginResponseModel 实例
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      userData: json['user'] as Map<String, dynamic>?,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      errorCode: json['error_code'] as String?,
    );
  }

  /// 转换为 JSON
  ///
  /// 用于缓存或日志记录（注意不要包含敏感信息）
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'success': success, 'message': message};

    if (userData != null) {
      json['user'] = userData;
    }

    if (expiresAt != null) {
      json['expires_at'] = expiresAt!.toIso8601String();
    }

    if (errorCode != null) {
      json['error_code'] = errorCode;
    }

    // 注意：不包含令牌信息以保证安全性

    return json;
  }

  /// 检查响应是否有效
  ///
  /// 验证响应数据的完整性
  bool get isValid {
    if (!success) {
      // 失败响应必须有错误信息
      return message.isNotEmpty;
    } else {
      // 成功响应必须有用户数据和令牌
      return userData != null && accessToken != null;
    }
  }

  /// 检查令牌是否过期
  ///
  /// 如果没有过期时间，默认认为未过期
  bool get isTokenExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 字符串表示
  @override
  String toString() {
    return 'LoginResponseModel('
        'success: $success, '
        'message: $message, '
        'hasUserData: ${userData != null}, '
        'hasToken: ${accessToken != null}, '
        'errorCode: $errorCode)';
  }
}
