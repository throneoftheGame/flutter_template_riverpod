/// 登录凭证实体类
///
/// 封装用户登录时使用的凭证信息
/// 支持多种登录方式：邮箱、用户名、手机号
class LoginCredential {
  /// 凭证值（邮箱、用户名或手机号）
  final String credential;

  /// 密码
  final String password;

  /// 登录类型
  final LoginType type;

  /// 国家代码（仅手机号登录时使用）
  final String? countryCode;

  /// 构造函数
  const LoginCredential({
    required this.credential,
    required this.password,
    required this.type,
    this.countryCode,
  });

  /// 创建邮箱登录凭证
  ///
  /// 工厂构造函数，用于创建邮箱登录的凭证
  factory LoginCredential.email({
    required String email,
    required String password,
  }) {
    return LoginCredential(
      credential: email,
      password: password,
      type: LoginType.email,
    );
  }

  /// 创建用户名登录凭证
  ///
  /// 工厂构造函数，用于创建用户名登录的凭证
  factory LoginCredential.username({
    required String username,
    required String password,
  }) {
    return LoginCredential(
      credential: username,
      password: password,
      type: LoginType.username,
    );
  }

  /// 创建手机号登录凭证
  ///
  /// 工厂构造函数，用于创建手机号登录的凭证
  factory LoginCredential.phone({
    required String phoneNumber,
    required String password,
    required String countryCode,
  }) {
    return LoginCredential(
      credential: phoneNumber,
      password: password,
      type: LoginType.phone,
      countryCode: countryCode,
    );
  }

  /// 获取完整的手机号（包含国家代码）
  ///
  /// 仅在手机号登录时有效
  String? get fullPhoneNumber {
    if (type != LoginType.phone || countryCode == null) {
      return null;
    }
    return '$countryCode$credential';
  }

  /// 业务规则：验证凭证格式是否正确
  ///
  /// 根据不同的登录类型进行相应的格式验证
  bool get isValidFormat {
    switch (type) {
      case LoginType.email:
        return _isValidEmail(credential);
      case LoginType.username:
        return _isValidUsername(credential);
      case LoginType.phone:
        return _isValidPhoneNumber(credential);
    }
  }

  /// 私有方法：验证邮箱格式
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// 私有方法：验证用户名格式
  bool _isValidUsername(String username) {
    // 用户名规则：3-20个字符，只能包含字母、数字、下划线
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username);
  }

  /// 私有方法：验证手机号格式
  bool _isValidPhoneNumber(String phone) {
    // 手机号规则：只能包含数字，长度在10-11位之间
    final phoneRegex = RegExp(r'^\d{10,11}$');
    return phoneRegex.hasMatch(phone);
  }

  /// 业务规则：验证密码强度
  ///
  /// 密码必须包含字母和数字，长度至少6位
  bool get isPasswordStrong {
    if (password.length < 6) return false;

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);

    return hasLetter && hasDigit;
  }

  /// 对象相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginCredential &&
        other.credential == credential &&
        other.password == password &&
        other.type == type &&
        other.countryCode == countryCode;
  }

  /// 哈希码
  @override
  int get hashCode {
    return Object.hash(credential, password, type, countryCode);
  }

  /// 字符串表示（隐藏密码）
  @override
  String toString() {
    return 'LoginCredential(credential: $credential, type: $type, '
        'countryCode: $countryCode, password: [HIDDEN])';
  }
}

/// 登录类型枚举
///
/// 定义系统支持的登录方式
enum LoginType {
  /// 邮箱登录
  email,

  /// 用户名登录
  username,

  /// 手机号登录
  phone,
}

/// 登录类型扩展
///
/// 为登录类型枚举添加便利方法
extension LoginTypeExtension on LoginType {
  /// 获取登录类型的显示名称
  String get displayName {
    switch (this) {
      case LoginType.email:
        return '邮箱';
      case LoginType.username:
        return '用户名';
      case LoginType.phone:
        return '手机号';
    }
  }

  /// 检查是否是手机号登录
  bool get isPhone => this == LoginType.phone;

  /// 检查是否是邮箱登录
  bool get isEmail => this == LoginType.email;

  /// 检查是否是用户名登录
  bool get isUsername => this == LoginType.username;
}
