# Flutter Template with Riverpod

一个基于 Flutter + Riverpod + Dio + SharedPreferences 的快速开发项目模板，集成了最佳实践和常用功能模块。

## 📱 预览

<div align="center">
  <img src="screenshots/home.png" width="250" alt="首页"/>
  <img src="screenshots/login.png" width="250" alt="登录页"/>
  <img src="screenshots/settings.png" width="250" alt="设置页"/>
</div>

## ✨ 特性

### 🎯 核心功能

- ✅ **Riverpod 状态管理** - 现代化的状态管理解决方案
- ✅ **Dio 网络请求** - 强大的 HTTP 客户端，支持拦截器、错误处理
- ✅ **SharedPreferences 本地存储** - 轻量级键值对存储
- ✅ **多主题支持** - 浅色/深色/跟随系统主题
- ✅ **国际化支持** - 中英文切换
- ✅ **错误处理** - 统一的异常处理机制
- ✅ **日志系统** - 基于 Talker 的日志管理

### 🏗️ 架构设计

- ✅ **Clean Architecture** - 分层架构，职责清晰
- ✅ **Feature-based** - 按功能模块组织代码
- ✅ **代码生成** - 自动生成样板代码
- ✅ **扩展方法** - 丰富的扩展方法提升开发效率
- ✅ **通用组件** - 可复用的 UI 组件库

### 🎨 UI/UX

- ✅ **Material Design 3** - 现代化的设计语言
- ✅ **响应式布局** - 适配不同屏幕尺寸
- ✅ **加载状态** - 优雅的加载动画
- ✅ **错误状态** - 友好的错误提示
- ✅ **空状态** - 美观的空数据展示

## 🚀 快速开始

### 环境要求

- Flutter SDK: >= 3.8.0
- Dart SDK: >= 3.8.0

### 安装步骤

1. **克隆项目**

   ```bash
   git clone <your-repo-url>
   cd flutter_template_riverpod
   ```

2. **安装依赖**

   ```bash
   flutter pub get
   ```

3. **生成代码**

   ```bash
   dart run build_runner build
   ```

4. **运行项目**
   ```bash
   flutter run
   ```

## 📁 项目结构

```
lib/
├── core/                    # 核心模块
│   ├── constants/          # 常量定义
│   ├── error/              # 错误处理
│   ├── extensions/         # 扩展方法
│   ├── network/            # 网络配置
│   ├── storage/            # 存储服务
│   └── utils/              # 工具类
├── features/               # 功能模块
│   ├── auth/               # 认证模块
│   ├── home/               # 首页模块
│   └── settings/           # 设置模块
├── shared/                 # 共享资源
│   ├── models/             # 数据模型
│   ├── providers/          # 状态提供者
│   └── widgets/            # 通用组件
├── app.dart               # 应用入口
└── main.dart              # 主函数
```

## 🔧 主要技术栈

| 功能     | 库                 | 版本   |
| -------- | ------------------ | ------ |
| 状态管理 | flutter_riverpod   | ^2.5.1 |
| 网络请求 | dio                | ^5.9.0 |
| 本地存储 | shared_preferences | ^2.5.3 |
| 日志系统 | talker_flutter     | ^5.0.0 |
| 代码生成 | riverpod_generator | ^2.4.3 |
| UI 组件  | google_fonts       | ^6.3.1 |
| 加载动画 | flutter_spinkit    | ^5.2.2 |
| 网络检测 | connectivity_plus  | ^6.1.5 |

## 📝 使用指南

### 状态管理

使用 Riverpod 进行状态管理：

```dart
// 定义 Provider
final counterProvider = StateProvider<int>((ref) => 0);

// 在 Widget 中使用
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Column(
      children: [
        Text('$count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: Text('增加'),
        ),
      ],
    );
  }
}
```

### 网络请求

使用 Dio 进行网络请求：

```dart
class ApiService {
  final DioClient _dioClient;

  ApiService(this._dioClient);

  Future<Result<User>> getUser(int id) async {
    try {
      final response = await _dioClient.get('/users/$id');
      final user = User.fromJson(response.data);
      return Result.success(user);
    } catch (e) {
      return Result.failure(NetworkFailure(e.toString()));
    }
  }
}
```

### 本地存储

使用 StorageService 进行数据存储：

```dart
// 存储数据
await ref.read(storageServiceProvider).setString('key', 'value');

// 读取数据
final value = await ref.read(storageServiceProvider).getString('key');

// 存储对象
await ref.read(storageServiceProvider).setObject(
  'user',
  user,
  (json) => User.fromJson(json),
);
```

### 主题切换

```dart
// 切换主题
ref.read(themeModeProvider.notifier).toggleThemeMode();

// 设置特定主题
ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
```

### 语言切换

```dart
// 切换语言
ref.read(localeProvider.notifier).toggleLocale();

// 设置特定语言
ref.read(localeProvider.notifier).setLocale(Locale('zh', 'CN'));
```

## 🎨 自定义配置

### 修改主题色

在 `lib/core/constants/app_constants.dart` 中修改：

```dart
static const Color primaryColor = Color(0xFF2196F3); // 修改为你的主色调
```

### 修改 API 基础地址

```dart
static const String baseUrl = 'https://your-api.com'; // 修改为你的API地址
```

### 添加新功能模块

1. 在 `lib/features/` 下创建新的功能目录
2. 按照现有结构创建 `data/`、`domain/`、`presentation/` 目录
3. 实现对应的数据层、业务层、表现层代码

## 🔍 代码生成

项目使用代码生成来减少样板代码：

```bash
# 一次性生成
dart run build_runner build

# 监听文件变化自动生成
dart run build_runner watch

# 删除冲突文件后重新生成
dart run build_runner build --delete-conflicting-outputs
```

## 📱 示例页面

### 登录页面

- 表单验证
- 加载状态
- 错误处理
- 第三方登录 UI

### 首页

- 卡片布局
- 快捷操作
- 主题切换
- 功能演示

### 设置页面

- 分组设置项
- 开关控件
- 对话框选择
- 确认操作

## 🐛 常见问题

### Q: 如何添加新的网络拦截器？

A: 在 `lib/core/network/dio_client.dart` 的 `_setupInterceptors` 方法中添加：

```dart
_dio.interceptors.add(YourCustomInterceptor());
```

### Q: 如何添加新的存储类型？

A: 在 `StorageService` 接口中添加新方法，然后在实现类中实现对应逻辑。

### Q: 如何自定义错误处理？

A: 修改 `lib/core/error/` 目录下的异常和失败类，以及网络拦截器中的错误处理逻辑。

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目基于 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [Flutter](https://flutter.dev/) - Google 的 UI 工具包
- [Riverpod](https://riverpod.dev/) - 状态管理解决方案
- [Dio](https://github.com/cfug/dio) - HTTP 客户端
- [GSY GitHub App Flutter](https://github.com/CarGuo/gsy_github_app_flutter) - 项目参考

## 📞 联系方式

如果您有任何问题或建议，请通过以下方式联系：

- 邮箱: your-email@example.com
- GitHub Issues: [提交问题](https://github.com/your-username/flutter_template_riverpod/issues)

---

⭐ 如果这个项目对您有帮助，请给个 Star 支持一下！
