/// String 扩展方法
extension StringExtensions on String {
  /// 是否为空或null
  bool get isNullOrEmpty => isEmpty;

  /// 是否不为空且不为null
  bool get isNotNullOrEmpty => isNotEmpty;

  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 首字母小写
  String get uncapitalize {
    if (isEmpty) return this;
    return '${this[0].toLowerCase()}${substring(1)}';
  }

  /// 移除所有空格
  String get removeAllSpaces => replaceAll(' ', '');

  /// 移除开头和结尾的空格
  String get trimmed => trim();

  /// 是否包含数字
  bool get hasNumbers => contains(RegExp(r'[0-9]'));

  /// 是否包含字母
  bool get hasLetters => contains(RegExp(r'[a-zA-Z]'));

  /// 是否包含特殊字符
  bool get hasSpecialCharacters => contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  /// 是否为有效邮箱
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// 是否为有效手机号（中国）
  bool get isValidPhoneNumber {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this);
  }

  /// 是否为有效URL
  bool get isValidUrl {
    return RegExp(r'^https?://').hasMatch(this);
  }

  /// 是否为数字
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// 转换为int，失败返回null
  int? get toIntOrNull => int.tryParse(this);

  /// 转换为double，失败返回null
  double? get toDoubleOrNull => double.tryParse(this);

  /// 限制字符串长度，超出部分用省略号表示
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// 将字符串转换为驼峰命名
  String get toCamelCase {
    return split(' ')
        .asMap()
        .entries
        .map(
          (entry) => entry.key == 0
              ? entry.value.toLowerCase()
              : entry.value.capitalize,
        )
        .join();
  }

  /// 将字符串转换为帕斯卡命名
  String get toPascalCase {
    return split(' ').map((word) => word.capitalize).join();
  }

  /// 将字符串转换为蛇形命名
  String get toSnakeCase {
    return toLowerCase().replaceAll(' ', '_');
  }

  /// 将字符串转换为短横线命名
  String get toKebabCase {
    return toLowerCase().replaceAll(' ', '-');
  }

  /// 反转字符串
  String get reversed {
    return split('').reversed.join();
  }

  /// 计算字符串的字节长度（UTF-8）
  int get byteLength {
    return runes.length;
  }

  /// 移除HTML标签
  String get removeHtmlTags {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 格式化文件大小
  String formatFileSize() {
    final bytes = int.tryParse(this);
    if (bytes == null) return this;

    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// 可空String扩展
extension NullableStringExtensions on String? {
  /// 是否为null或空
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// 是否不为null且不为空
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// 获取值或默认值
  String orEmpty() => this ?? '';

  /// 获取值或指定默认值
  String orDefault(String defaultValue) => this ?? defaultValue;
}
