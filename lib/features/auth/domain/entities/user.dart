/// 用户实体类
///
/// 这是领域层的核心实体，代表系统中的用户概念
/// 特点：
/// 1. 纯 Dart 类，不依赖任何框架
/// 2. 包含用户的基本属性和业务规则
/// 3. 不包含数据序列化逻辑（那属于 Data 层）
class User {
  /// 用户唯一标识符
  final String id;

  /// 用户邮箱地址
  final String email;

  /// 用户显示名称
  final String name;

  /// 用户头像 URL（可选）
  final String? avatarUrl;

  /// 用户手机号码（可选）
  final String? phoneNumber;

  /// 账号创建时间
  final DateTime createdAt;

  /// 最后登录时间（可选）
  final DateTime? lastLoginAt;

  /// 账号是否已验证
  final bool isVerified;

  /// 构造函数
  ///
  /// 使用命名参数确保必要字段不会被遗漏
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.isVerified,
    this.avatarUrl,
    this.phoneNumber,
    this.lastLoginAt,
  });

  /// 业务规则：检查用户是否是新用户
  ///
  /// 定义：注册后7天内的用户被认为是新用户
  bool get isNewUser {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7;
  }

  /// 业务规则：检查用户是否长时间未登录
  ///
  /// 定义：超过30天未登录的用户被认为是不活跃用户
  bool get isInactiveUser {
    if (lastLoginAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt!);
    return difference.inDays > 30;
  }

  /// 业务规则：获取用户显示名称
  ///
  /// 优先显示用户名，如果没有则显示邮箱前缀
  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  /// 复制对象并修改某些属性
  ///
  /// 用于创建新的用户实例，常用于状态更新
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// 对象相等性比较
  ///
  /// 基于用户 ID 进行比较，因为 ID 是唯一标识符
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  /// 哈希码
  ///
  /// 基于用户 ID 生成，确保相同 ID 的用户有相同的哈希码
  @override
  int get hashCode => id.hashCode;

  /// 字符串表示
  ///
  /// 用于调试和日志输出
  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, isVerified: $isVerified)';
  }
}
