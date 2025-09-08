import '../../domain/entities/user.dart';

/// 用户数据模型
///
/// 这是数据层的模型类，负责数据的序列化和反序列化
/// 特点：
/// 1. 继承自领域层的 User 实体
/// 2. 添加了 JSON 序列化功能
/// 3. 处理 API 响应和本地存储的数据转换
/// 4. 包含数据验证和默认值处理
class UserModel extends User {
  /// 构造函数
  ///
  /// 调用父类构造函数，确保所有必要字段都被初始化
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.createdAt,
    required super.isVerified,
    super.avatarUrl,
    super.phoneNumber,
    super.lastLoginAt,
  });

  /// 从 JSON 创建 UserModel 实例
  ///
  /// 用于解析 API 响应或本地存储的 JSON 数据
  ///
  /// 参数：
  /// - [json] JSON 数据 Map
  ///
  /// 返回值：
  /// - UserModel 实例
  ///
  /// 注意：
  /// - 处理了可能的空值和类型转换
  /// - 提供了默认值以防数据不完整
  /// - 包含日期字符串的解析逻辑
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // 必需字段，如果缺失会抛出异常
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',

      // 布尔值字段，默认为 false
      isVerified: json['is_verified'] as bool? ?? false,

      // 日期字段，需要从字符串解析
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),

      // 可选字段，可以为 null
      avatarUrl: json['avatar_url'] as String?,
      phoneNumber: json['phone_number'] as String?,

      // 可选日期字段
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  /// 从领域实体创建 UserModel
  ///
  /// 用于将领域层的 User 实体转换为数据模型
  /// 在需要序列化用户数据时使用
  ///
  /// 参数：
  /// - [user] 领域层的 User 实体
  ///
  /// 返回值：
  /// - UserModel 实例
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      avatarUrl: user.avatarUrl,
      phoneNumber: user.phoneNumber,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      isVerified: user.isVerified,
    );
  }

  /// 转换为 JSON
  ///
  /// 用于 API 请求或本地存储
  ///
  /// 返回值：
  /// - JSON 数据 Map
  ///
  /// 注意：
  /// - 使用下划线命名法，符合 API 规范
  /// - 处理了日期转字符串的逻辑
  /// - 过滤了 null 值以减少数据大小
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };

    // 只添加非 null 的可选字段
    if (avatarUrl != null) {
      json['avatar_url'] = avatarUrl;
    }

    if (phoneNumber != null) {
      json['phone_number'] = phoneNumber;
    }

    if (lastLoginAt != null) {
      json['last_login_at'] = lastLoginAt!.toIso8601String();
    }

    return json;
  }

  /// 转换为领域实体
  ///
  /// 将数据模型转换回领域层的实体
  /// 用于向上层传递数据时使用
  ///
  /// 返回值：
  /// - User 领域实体
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      isVerified: isVerified,
    );
  }

  /// 创建副本并修改某些属性
  ///
  /// 重写父类的 copyWith 方法，返回 UserModel 类型
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isVerified,
  }) {
    return UserModel(
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

  /// 验证模型数据的有效性
  ///
  /// 检查从外部数据源获取的数据是否符合业务规则
  ///
  /// 返回值：
  /// - true: 数据有效
  /// - false: 数据无效
  ///
  /// 验证规则：
  /// - ID 不能为空
  /// - 邮箱格式必须正确
  /// - 名称不能为空
  bool get isValid {
    // 检查必需字段
    if (id.isEmpty || email.isEmpty || name.isEmpty) {
      return false;
    }

    // 检查邮箱格式
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    // 检查手机号格式（如果存在）
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+\d{1,4}\d{10,11}$');
      if (!phoneRegex.hasMatch(phoneNumber!)) {
        return false;
      }
    }

    return true;
  }

  /// 获取用于缓存的键
  ///
  /// 生成用于本地缓存的唯一标识符
  String get cacheKey => 'user_$id';

  /// 字符串表示
  ///
  /// 重写父类的 toString 方法，添加模型特有的信息
  @override
  String toString() {
    return 'UserModel('
        'id: $id, '
        'email: $email, '
        'name: $name, '
        'isVerified: $isVerified, '
        'isValid: $isValid)';
  }
}
