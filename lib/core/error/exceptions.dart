/// 应用异常基类
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// 认证异常
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// 解析异常
class ParseException extends AppException {
  const ParseException(super.message, [super.code]);
}

/// 业务异常
class BusinessException extends AppException {
  const BusinessException(super.message, [super.code]);
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}
