import 'package:dio/dio.dart';
import '../../error/exceptions.dart';
import '../../utils/logger.dart';

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const NetworkException('连接超时，请检查网络连接');
        break;

      case DioExceptionType.badResponse:
        exception = _handleResponseError(err);
        break;

      case DioExceptionType.cancel:
        exception = const NetworkException('请求已取消');
        break;

      case DioExceptionType.connectionError:
        exception = const NetworkException('网络连接错误，请检查网络设置');
        break;

      case DioExceptionType.badCertificate:
        exception = const NetworkException('证书验证失败');
        break;

      case DioExceptionType.unknown:
      default:
        exception = NetworkException('网络请求失败: ${err.message}');
        break;
    }

    AppLogger.error('Network error', exception);

    // 将异常信息添加到错误中
    final dioError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: exception,
      message: exception.message,
    );

    handler.next(dioError);
  }

  /// 处理响应错误
  AppException _handleResponseError(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // 尝试从响应中获取错误信息
    String message = '服务器错误';
    String? code;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['msg'] ?? message;
      code = data['code']?.toString();
    }

    switch (statusCode) {
      case 400:
        return BusinessException('请求参数错误: $message', code);
      case 401:
        return const AuthException('未授权，请重新登录');
      case 403:
        return const AuthException('权限不足，访问被拒绝');
      case 404:
        return const ServerException('请求的资源不存在');
      case 422:
        return BusinessException('数据验证失败: $message', code);
      case 429:
        return const NetworkException('请求过于频繁，请稍后再试');
      case 500:
        return const ServerException('服务器内部错误');
      case 502:
        return const ServerException('网关错误');
      case 503:
        return const ServerException('服务暂不可用');
      case 504:
        return const ServerException('网关超时');
      default:
        return ServerException('服务器错误: $message', code);
    }
  }
}
