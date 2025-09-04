# 开发指南

本文档为 Flutter Template 项目的开发指南，包含开发规范、最佳实践和常用命令。

## 🏗️ 项目架构

### Clean Architecture

项目采用 Clean Architecture 分层架构：

```
lib/
├── core/                    # 核心层 - 基础设施和工具
├── features/               # 特性层 - 业务功能模块
└── shared/                 # 共享层 - 通用资源
```

### 功能模块结构

每个功能模块按照以下结构组织：

```
features/auth/
├── data/                   # 数据层
│   ├── datasources/       # 数据源（API、本地存储）
│   ├── models/            # 数据模型
│   └── repositories/      # 仓库实现
├── domain/                # 领域层
│   ├── entities/          # 业务实体
│   ├── repositories/      # 仓库接口
│   └── usecases/          # 用例
└── presentation/          # 表现层
    ├── pages/             # 页面
    ├── widgets/           # 组件
    └── providers/         # 状态管理
```

## 🔧 开发环境配置

### 必需工具

1. **Flutter SDK**: >= 3.8.0
2. **Dart SDK**: >= 3.8.0
3. **IDE**: VS Code 或 Android Studio
4. **Git**: 版本控制

### VS Code 推荐插件

```json
{
  "recommendations": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss",
    "formulahendry.auto-rename-tag"
  ]
}
```

### 项目初始化

```bash
# 1. 克隆项目
git clone <repository-url>
cd flutter_template_riverpod

# 2. 安装依赖
flutter pub get

# 3. 生成代码
dart run build_runner build

# 4. 运行项目
flutter run
```

## 📝 开发规范

### 代码风格

项目使用 `flutter_lints` 进行代码规范检查：

```bash
# 检查代码规范
flutter analyze

# 格式化代码
dart format lib/
```

### 命名规范

- **文件名**: 使用下划线命名 `snake_case`
- **类名**: 使用帕斯卡命名 `PascalCase`
- **变量名**: 使用驼峰命名 `camelCase`
- **常量名**: 使用驼峰命名 `camelCase`
- **枚举值**: 使用驼峰命名 `camelCase`

```dart
// 文件名
user_profile_page.dart

// 类名
class UserProfilePage extends StatelessWidget {}

// 变量名
final userName = 'John';

// 常量名
static const maxRetryCount = 3;

// 枚举
enum UserStatus { active, inactive, pending }
```

### 目录结构规范

```dart
// ✅ 正确的导入顺序
import 'dart:async';                    // Dart 核心库
import 'dart:io';

import 'package:flutter/material.dart';  // Flutter 库
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';           // 第三方库
import 'package:riverpod/riverpod.dart';

import '../../../core/constants.dart';   // 项目内部导入
import '../widgets/custom_button.dart';
```

## 🎯 状态管理最佳实践

### Riverpod 使用规范

1. **Provider 命名**

   ```dart
   // ✅ 好的命名
   final userProvider = StateProvider<User?>((ref) => null);
   final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(...);

   // ❌ 避免的命名
   final provider1 = StateProvider<User?>((ref) => null);
   final data = StateNotifierProvider<ThemeNotifier, ThemeMode>(...);
   ```

2. **Provider 组织**

   ```dart
   // 将相关的 Provider 放在同一个文件中
   // lib/shared/providers/user_providers.dart
   final userProvider = StateProvider<User?>((ref) => null);
   final userProfileProvider = FutureProvider<UserProfile>((ref) => ...);
   final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>(...);
   ```

3. **StateNotifier 使用**

   ```dart
   class CounterNotifier extends StateNotifier<int> {
     CounterNotifier() : super(0);

     void increment() => state++;
     void decrement() => state--;
     void reset() => state = 0;
   }

   final counterProvider = StateNotifierProvider<CounterNotifier, int>(
     (ref) => CounterNotifier(),
   );
   ```

### 异步状态处理

```dart
// 使用 AsyncValue 处理异步状态
final userDataProvider = FutureProvider<User>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.getCurrentUser();
});

// 在 UI 中处理异步状态
class UserWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);

    return userData.when(
      data: (user) => Text(user.name),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## 🌐 网络请求最佳实践

### API 服务结构

```dart
abstract class UserApiService {
  Future<Result<User>> getUser(int id);
  Future<Result<List<User>>> getUsers();
  Future<Result<User>> createUser(CreateUserRequest request);
}

class UserApiServiceImpl implements UserApiService {
  final DioClient _dioClient;

  UserApiServiceImpl(this._dioClient);

  @override
  Future<Result<User>> getUser(int id) async {
    try {
      final response = await _dioClient.get('/users/$id');
      final user = User.fromJson(response.data);
      return Result.success(user);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
```

### 错误处理

```dart
// 统一的错误处理
Failure _handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return const NetworkFailure('连接超时');
    case DioExceptionType.badResponse:
      return ServerFailure('服务器错误: ${error.response?.statusCode}');
    default:
      return NetworkFailure(error.message ?? '网络错误');
  }
}
```

## 💾 数据存储最佳实践

### 存储服务使用

```dart
// 存储用户偏好
class UserPreferences {
  final StorageService _storage;

  UserPreferences(this._storage);

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.setString('theme_mode', mode.name);
  }

  Future<ThemeMode> getThemeMode() async {
    final modeString = await _storage.getString('theme_mode');
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == modeString,
      orElse: () => ThemeMode.system,
    );
  }
}
```

### 数据模型

```dart
@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
```

## 🎨 UI 开发最佳实践

### 组件设计原则

1. **单一职责**: 每个组件只做一件事
2. **可复用**: 通过参数配置不同状态
3. **可组合**: 小组件组合成大组件
4. **一致性**: 遵循设计系统

### 自定义组件示例

```dart
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: _getButtonStyle(context),
      child: isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(text),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    // 实现按钮样式逻辑
  }
}
```

### 响应式设计

```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout();
        } else if (constraints.maxWidth < 1200) {
          return _buildTabletLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }
}
```

## 🧪 测试最佳实践

### 单元测试

```dart
// test/providers/counter_provider_test.dart
void main() {
  group('CounterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with 0', () {
      expect(container.read(counterProvider), 0);
    });

    test('should increment counter', () {
      container.read(counterProvider.notifier).increment();
      expect(container.read(counterProvider), 1);
    });
  });
}
```

### Widget 测试

```dart
// test/widgets/custom_button_test.dart
void main() {
  group('CustomButton', () {
    testWidgets('should display text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomButton(
            text: 'Test Button',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CustomButton(
            text: 'Test Button',
            onPressed: () => wasPressed = true,
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      expect(wasPressed, true);
    });
  });
}
```

## 🚀 常用开发命令

### 代码生成

```bash
# 一次性生成
dart run build_runner build

# 监听文件变化
dart run build_runner watch

# 删除冲突文件后生成
dart run build_runner build --delete-conflicting-outputs
```

### 代码质量

```bash
# 分析代码
flutter analyze

# 格式化代码
dart format lib/ test/

# 运行测试
flutter test

# 生成测试覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 构建发布

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📊 性能优化

### 常见优化策略

1. **使用 const 构造函数**

   ```dart
   // ✅ 好的做法
   const Text('Hello World')

   // ❌ 避免
   Text('Hello World')
   ```

2. **合理使用 ListView.builder**

   ```dart
   // ✅ 大列表使用 builder
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) => ItemWidget(items[index]),
   )
   ```

3. **避免在 build 方法中创建对象**
   ```dart
   class MyWidget extends StatelessWidget {
     // ✅ 在类级别定义
     static const textStyle = TextStyle(fontSize: 16);

     @override
     Widget build(BuildContext context) {
       return Text('Hello', style: textStyle);
     }
   }
   ```

## 🔒 安全最佳实践

### API 密钥管理

```dart
// 使用环境变量或配置文件
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static const String apiKey = String.fromEnvironment('API_KEY');
}
```

### 数据验证

```dart
// 输入验证
class Validators {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return '请输入邮箱地址';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }
}
```

## 📝 提交规范

### Git 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 提交类型

- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

### 示例

```
feat(auth): 添加用户登录功能

- 实现用户名密码登录
- 添加表单验证
- 集成第三方登录

Closes #123
```

## 🤝 团队协作

### 分支策略

- `main`: 主分支，稳定版本
- `develop`: 开发分支
- `feature/*`: 功能分支
- `hotfix/*`: 热修复分支

### Code Review 检查清单

- [ ] 代码符合项目规范
- [ ] 功能实现正确
- [ ] 包含必要的测试
- [ ] 文档已更新
- [ ] 性能影响评估
- [ ] 安全性检查

---

这份开发指南会随着项目的发展持续更新，请定期查看最新版本。
