/// 失败结果基类
abstract class Failure {
  const Failure(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 网络失败
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// 服务器失败
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// 认证失败
class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// 解析失败
class ParseFailure extends Failure {
  const ParseFailure(super.message, [super.code]);
}

/// 业务失败
class BusinessFailure extends Failure {
  const BusinessFailure(super.message, [super.code]);
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.code]);
}
