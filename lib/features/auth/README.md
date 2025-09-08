# 认证模块 - Clean Architecture 实现

这个认证模块是 Clean Architecture（清洁架构）的完整实现示例，展示了如何在 Flutter 项目中组织代码结构。

## 📁 目录结构

```
features/auth/
├── data/                           # 数据层 (Data Layer)
│   ├── datasources/               # 数据源
│   │   ├── auth_remote_datasource.dart    # 远程数据源（API）
│   │   └── auth_local_datasource.dart     # 本地数据源（缓存）
│   ├── models/                    # 数据模型
│   │   ├── user_model.dart               # 用户数据模型
│   │   └── login_request_model.dart      # 登录请求模型
│   └── repositories/              # 仓库实现
│       └── auth_repository_impl.dart     # 认证仓库实现
├── domain/                        # 领域层 (Domain Layer)
│   ├── entities/                  # 业务实体
│   │   ├── user.dart                     # 用户实体
│   │   └── login_credential.dart         # 登录凭证实体
│   ├── repositories/              # 仓库接口
│   │   └── auth_repository.dart          # 认证仓库接口
│   └── usecases/                  # 用例
│       └── login_usecase.dart            # 登录用例
├── presentation/                  # 表现层 (Presentation Layer)
│   ├── pages/                     # 页面
│   │   ├── login_page.dart               # 原始登录页面
│   │   └── login_page_example.dart       # 新架构示例页面
│   └── providers/                 # 状态管理
│       └── auth_provider.dart            # 认证状态提供者
└── README.md                      # 本文档
```

## 🏗️ 架构层次

### 1. Domain Layer (领域层) 🧠

**职责**: 包含业务逻辑和业务规则，是整个应用的核心。

#### 实体 (Entities)

- **`User`**: 用户业务实体

  - 包含用户的基本属性
  - 定义业务规则（如：是否是新用户、是否不活跃等）
  - 不依赖任何外部框架

- **`LoginCredential`**: 登录凭证实体
  - 封装登录信息（邮箱、用户名、手机号）
  - 包含验证逻辑（格式验证、密码强度检查）
  - 支持多种登录方式

#### 仓库接口 (Repository Interfaces)

- **`AuthRepository`**: 认证仓库接口
  - 定义所有认证相关操作的契约
  - 使用 `Result` 类型统一处理成功和失败情况
  - 不包含具体实现，只定义接口

#### 用例 (Use Cases)

- **`LoginUseCase`**: 登录用例
  - 包含完整的登录业务流程
  - 验证输入、调用仓库、处理结果
  - 生成业务相关的欢迎消息和状态判断

### 2. Data Layer (数据层) 💾

**职责**: 处理数据的获取、存储和转换。

#### 数据源 (Data Sources)

- **`AuthRemoteDataSource`**: 远程数据源

  - 处理所有与后端 API 的网络通信
  - HTTP 请求封装和错误处理
  - 响应数据解析和验证

- **`AuthLocalDataSource`**: 本地数据源
  - 本地数据存储和缓存管理
  - 认证令牌的安全存储
  - 离线数据访问支持

#### 数据模型 (Models)

- **`UserModel`**: 用户数据模型

  - JSON 序列化和反序列化
  - 数据验证和默认值处理
  - 与领域实体的转换

- **`LoginRequestModel`**: 登录请求模型
  - API 请求数据格式化
  - 设备信息和安全审计数据

#### 仓库实现 (Repository Implementation)

- **`AuthRepositoryImpl`**: 认证仓库实现
  - 实现领域层定义的仓库接口
  - 协调远程和本地数据源
  - 缓存策略和数据一致性保证
  - 异常处理和错误转换

### 3. Presentation Layer (表现层) 📱

**职责**: 用户界面和用户交互处理。

#### 状态管理 (State Management)

- **`AuthProvider`**: 认证状态提供者
  - 使用 Riverpod 管理全局认证状态
  - 调用领域层用例执行业务操作
  - UI 状态管理和错误处理

#### 页面 (Pages)

- **`LoginPage`**: 原始登录页面（UI 和业务逻辑混合）
- **`LoginPageExample`**: 新架构示例页面（使用 Clean Architecture）

## 🔄 数据流向

```
UI (LoginPage)
    ↓ 用户操作
Provider (AuthProvider)
    ↓ 调用用例
UseCase (LoginUseCase)
    ↓ 调用仓库接口
Repository (AuthRepositoryImpl)
    ↓ 协调数据源
DataSource (Remote/Local)
    ↓ 网络请求/本地存储
API/Cache
    ↓ 数据返回
... (相同路径返回)
```

## 📋 使用示例

### 1. 创建登录凭证

```dart
// 邮箱登录
final emailCredential = LoginCredential.email(
  email: 'user@example.com',
  password: 'password123',
);

// 用户名登录
final usernameCredential = LoginCredential.username(
  username: 'johndoe',
  password: 'password123',
);

// 手机号登录
final phoneCredential = LoginCredential.phone(
  phoneNumber: '13800138000',
  password: 'password123',
  countryCode: '+86',
);
```

### 2. 使用状态管理

```dart
class LoginWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Column(
      children: [
        if (authState.isLoading)
          CircularProgressIndicator(),

        if (authState.hasError)
          Text(authState.error!),

        ElevatedButton(
          onPressed: () async {
            final success = await ref
                .read(authProvider.notifier)
                .login(credential);

            if (success) {
              // 登录成功处理
            }
          },
          child: Text('登录'),
        ),
      ],
    );
  }
}
```

### 3. 监听状态变化

```dart
ref.listen<AuthState>(authProvider, (previous, next) {
  if (next.isAuthenticated) {
    // 导航到主页
    Navigator.pushReplacementNamed(context, '/home');
  }

  if (next.hasError) {
    // 显示错误消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.error!)),
    );
  }
});
```

## 🧪 测试策略

### 单元测试

每层都可以独立测试：

```dart
// 测试领域层实体
test('User should be new user within 7 days', () {
  final user = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: DateTime.now().subtract(Duration(days: 5)),
    isVerified: true,
  );

  expect(user.isNewUser, true);
});

// 测试用例
test('LoginUseCase should validate credentials', () async {
  final mockRepository = MockAuthRepository();
  final useCase = LoginUseCase(mockRepository);

  final credential = LoginCredential.email(
    email: 'invalid-email',
    password: '123',
  );

  final result = await useCase.execute(credential);
  expect(result.isFailure, true);
});

// 测试状态管理
testWidgets('AuthProvider should update state on login', (tester) async {
  // 测试状态变化逻辑
});
```

### 集成测试

测试整个认证流程：

```dart
testWidgets('Complete login flow', (tester) async {
  // 1. 渲染登录页面
  // 2. 输入用户凭证
  // 3. 点击登录按钮
  // 4. 验证状态变化
  // 5. 验证页面跳转
});
```

## 🔧 依赖注入配置

```dart
// providers.dart
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // 异步初始化 SharedPreferences
  throw UnimplementedError('Initialize SharedPreferences');
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(prefs);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource, localDataSource);
});
```

## ✅ 优势总结

1. **职责分离**: 每层只关心自己的职责，代码更清晰
2. **可测试性**: 每层都可以独立测试，提高代码质量
3. **可维护性**: 修改一层不会影响其他层，降低维护成本
4. **可扩展性**: 容易添加新功能或修改现有功能
5. **依赖倒置**: 高层模块不依赖低层模块，提高灵活性
6. **重用性**: 业务逻辑可以在不同的 UI 中重用
7. **独立性**: 各层可以独立开发和部署

## 📚 相关资源

- [Clean Architecture (Robert C. Martin)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Guide](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Result Pattern in Dart](https://pub.dev/packages/result_type)

---

这个架构实现提供了一个完整的、可扩展的认证模块，可以作为其他功能模块的参考模板。
