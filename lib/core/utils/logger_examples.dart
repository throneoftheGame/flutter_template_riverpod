import 'logger.dart';

/// 日志使用示例和最佳实践
class LoggerExamples {
  /// 调试日志示例
  static void debugExamples() {
    // 基本调试信息
    AppLogger.debug('用户点击了登录按钮');

    // 带变量的调试信息
    final userId = '12345';
    AppLogger.debug('用户ID: $userId 开始登录流程');

    // 状态变化日志
    AppLogger.debug('主题模式从 light 切换到 dark');

    // 页面导航日志
    AppLogger.debug('导航到设置页面');
  }

  /// 信息日志示例
  static void infoExamples() {
    // 应用启动信息
    AppLogger.info('应用启动完成，版本: 1.0.0');

    // 网络请求信息
    AppLogger.info('API请求: GET /api/users');
    AppLogger.info('API响应: 200 OK, 耗时: 234ms');

    // 用户操作信息
    AppLogger.info('用户登录成功');
    AppLogger.info('数据同步完成');

    // 性能信息
    AppLogger.info('页面渲染完成，耗时: 156ms');
  }

  /// 警告日志示例
  static void warningExamples() {
    // 性能警告
    AppLogger.warning('API响应时间过长: 5.2秒');

    // 数据验证警告
    AppLogger.warning('用户输入的邮箱格式可能不正确');

    // 功能降级警告
    AppLogger.warning('网络不稳定，启用离线模式');

    // 配置警告
    AppLogger.warning('未找到缓存配置，使用默认值');
  }

  /// 错误日志示例
  static void errorExamples() {
    try {
      // 模拟网络错误
      throw Exception('网络连接失败');
    } catch (e, stackTrace) {
      AppLogger.error('网络请求失败', e, stackTrace);
    }

    try {
      // 模拟数据解析错误
      throw FormatException('JSON解析失败');
    } catch (e, stackTrace) {
      AppLogger.error('数据解析错误', e, stackTrace);
    }

    // 业务逻辑错误
    AppLogger.error('用户权限不足，无法访问此功能');
  }

  /// 严重错误日志示例
  static void criticalExamples() {
    try {
      // 模拟系统级错误
      throw StateError('应用状态异常');
    } catch (e, stackTrace) {
      AppLogger.critical('应用状态异常，可能需要重启', e, stackTrace);
    }

    // 数据丢失错误
    AppLogger.critical('用户数据丢失，正在尝试恢复');

    // 安全相关错误
    AppLogger.critical('检测到异常登录尝试');
  }

  /// 网络请求日志示例
  static void networkLogExamples() {
    final url = 'https://api.example.com/users';
    final method = 'GET';

    // 请求开始
    AppLogger.info('🌐 [$method] $url - 请求开始');

    // 请求参数
    final params = {'page': 1, 'limit': 20};
    AppLogger.debug('📤 请求参数: $params');

    // 请求头
    final headers = {'Authorization': 'Bearer token'};
    AppLogger.debug('📋 请求头: ${headers.keys.join(', ')}');

    // 响应成功
    AppLogger.info('✅ [$method] $url - 200 OK (234ms)');

    // 响应数据
    AppLogger.debug('📥 响应数据大小: 1.2KB');
  }

  /// 用户操作日志示例
  static void userActionExamples() {
    // 页面访问
    AppLogger.info('👤 用户访问首页');

    // 按钮点击
    AppLogger.debug('🔘 用户点击登录按钮');

    // 表单提交
    AppLogger.info('📝 用户提交注册表单');

    // 搜索操作
    final searchTerm = 'Flutter';
    AppLogger.info('🔍 用户搜索: $searchTerm');

    // 设置更改
    AppLogger.info('⚙️ 用户切换到暗色主题');
  }

  /// 性能监控日志示例
  static void performanceLogExamples() {
    // 页面加载时间
    AppLogger.info('⚡ 首页加载完成: 156ms');

    // 网络请求耗时
    AppLogger.info('⏱️ API请求耗时: 234ms');

    // 数据库操作耗时
    AppLogger.debug('💾 数据库查询耗时: 45ms');

    // 图片加载耗时
    AppLogger.debug('🖼️ 图片加载完成: 89ms');

    // 内存使用情况
    AppLogger.debug('🧠 当前内存使用: 45MB');
  }

  /// 错误处理最佳实践
  static void errorHandlingBestPractices() {
    // ✅ 好的做法：提供上下文信息
    try {
      // 业务逻辑
    } catch (e, stackTrace) {
      AppLogger.error(
        '用户登录失败 - 用户ID: 12345, 尝试时间: ${DateTime.now()}',
        e,
        stackTrace,
      );
    }

    // ✅ 好的做法：记录恢复操作
    try {
      // 网络请求
    } catch (e) {
      AppLogger.warning('网络请求失败，正在重试...', e);
      // 重试逻辑
      AppLogger.info('重试成功');
    }

    // ✅ 好的做法：分级记录
    final responseTime = 5000; // ms
    if (responseTime > 3000) {
      AppLogger.warning('API响应时间过长: ${responseTime}ms');
    } else if (responseTime > 1000) {
      AppLogger.info('API响应时间: ${responseTime}ms');
    } else {
      AppLogger.debug('API响应时间: ${responseTime}ms');
    }
  }

  /// 日志格式化示例
  static void logFormattingExamples() {
    // 使用表情符号分类
    AppLogger.debug('🔍 调试信息');
    AppLogger.info('ℹ️ 普通信息');
    AppLogger.warning('⚠️ 警告信息');
    AppLogger.error('❌ 错误信息');
    AppLogger.critical('🚨 严重错误');

    // 使用前缀分类
    AppLogger.debug('[UI] 按钮点击事件');
    AppLogger.info('[API] 请求发送成功');
    AppLogger.warning('[CACHE] 缓存即将过期');
    AppLogger.error('[AUTH] 认证失败');

    // 结构化日志
    final logData = {
      'action': 'user_login',
      'userId': '12345',
      'timestamp': DateTime.now().toIso8601String(),
      'success': true,
    };
    AppLogger.info('用户操作日志: $logData');
  }
}
