import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';

/// 认证拦截器
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // 获取存储的token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyUserToken);

      if (token != null && token.isNotEmpty) {
        // 添加认证头
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.debug('Added auth token to request: ${options.path}');
      }
    } catch (e) {
      AppLogger.error('Failed to add auth token', e);
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 处理401未授权错误
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Received 401 Unauthorized, clearing token');

      try {
        // 清除过期的token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.keyUserToken);
        await prefs.remove(AppConstants.keyUserInfo);

        // 可以在这里触发登出逻辑
        // 例如：导航到登录页面
      } catch (e) {
        AppLogger.error('Failed to clear auth data', e);
      }
    }

    handler.next(err);
  }
}
