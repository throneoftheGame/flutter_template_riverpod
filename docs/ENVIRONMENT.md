# 环境配置管理

本项目支持多环境配置，包括开发、灰度、正式三个环境。

## 🌟 环境类型

### 开发环境 (Development)
- **用途**: 本地开发和测试
- **特性**: 
  - 启用详细日志
  - 显示调试横幅
  - 不启用崩溃统计
  - API地址: `https://dev-api.example.com`

### 灰度环境 (Staging)
- **用途**: 预发布测试
- **特性**:
  - 启用日志
  - 启用崩溃统计
  - 显示调试横幅
  - API地址: `https://staging-api.example.com`

### 正式环境 (Production)
- **用途**: 生产发布
- **特性**:
  - 关闭日志
  - 启用崩溃统计和数据统计
  - 隐藏调试横幅
  - API地址: `https://api.example.com`

## 🚀 启动方式

### 1. 使用脚本启动

```bash
# 开发环境
./scripts/run_dev.sh

# 灰度环境  
./scripts/run_staging.sh

# 正式环境构建
./scripts/run_prod.sh

# 构建所有环境
./scripts/build_all.sh
```

### 2. 使用 Flutter 命令

```bash
# 开发环境
flutter run --dart-define=ENVIRONMENT=development

# 灰度环境
flutter run --dart-define=ENVIRONMENT=staging

# 正式环境
flutter run --dart-define=ENVIRONMENT=production
```

### 3. 使用 VS Code

在 VS Code 中，按 `F5` 或 `Cmd+Shift+D` 打开调试面板，选择对应的环境配置：

- `Flutter Development`
- `Flutter Staging`
- `Flutter Production`

### 4. 使用代码入口

```dart
import 'package:flutter_template_riverpod/main.dart';

void main() {
  // 开发环境
  mainDevelopment();
  
  // 灰度环境
  // mainStaging();
  
  // 正式环境
  // mainProduction();
}
```

## ⚙️ 环境配置

### 配置文件结构

```
lib/core/config/
├── app_environment.dart      # 环境枚举定义
├── environment_config.dart   # 环境配置类
└── app_config.dart          # 配置管理器
```

### 添加新的环境配置

1. 在 `EnvironmentConfig` 中添加新的静态配置：

```dart
static const newEnvironment = EnvironmentConfig._(
  environment: AppEnvironment.newEnvironment,
  appName: 'Flutter Template (New)',
  apiBaseUrl: 'https://new-api.example.com',
  // ... 其他配置
);
```

2. 在 `AppEnvironment` 枚举中添加新环境。

3. 更新相关的扩展方法和工厂方法。

### 配置项说明

| 配置项 | 类型 | 说明 |
|--------|------|------|
| `environment` | `AppEnvironment` | 当前环境类型 |
| `appName` | `String` | 应用显示名称 |
| `apiBaseUrl` | `String` | API基础URL |
| `apiTimeout` | `int` | 网络请求超时时间(ms) |
| `enableLogging` | `bool` | 是否启用日志 |
| `enableCrashlytics` | `bool` | 是否启用崩溃统计 |
| `enableAnalytics` | `bool` | 是否启用数据统计 |
| `showPerformanceOverlay` | `bool` | 是否显示性能叠加层 |
| `debugShowCheckedModeBanner` | `bool` | 是否显示调试横幅 |

## 🎯 使用示例

### 在代码中获取环境配置

```dart
import 'package:flutter_template_riverpod/core/config/app_config.dart';

// 获取当前环境
final environment = AppConfig.instance.environment;

// 获取API地址
final apiUrl = AppConfig.instance.apiBaseUrl;

// 检查环境类型
if (AppConfig.instance.isDevelopment) {
  print('当前为开发环境');
}

// 根据环境执行不同逻辑
if (AppConfig.instance.enableLogging) {
  logger.debug('这条日志只在启用日志的环境中显示');
}
```

### 网络请求自动配置

网络客户端会自动根据环境配置：

- API基础URL
- 请求超时时间
- 是否启用请求日志
- 添加环境标识头 `X-Environment`

### 环境信息显示

项目包含多个环境信息显示组件：

- `EnvironmentBanner`: 在应用右上角显示环境横幅
- `EnvironmentInfoCard`: 详细的环境信息卡片
- `QuickEnvironmentInfo`: 快速环境标识

## 🔧 构建配置

### Android 构建

可以配置不同的 flavor 来对应不同环境：

```gradle
// android/app/build.gradle
flavorDimensions "environment"
productFlavors {
    development {
        dimension "environment"
        applicationIdSuffix ".dev"
        versionNameSuffix "-dev"
    }
    staging {
        dimension "environment"
        applicationIdSuffix ".staging"
        versionNameSuffix "-staging"
    }
    production {
        dimension "environment"
    }
}
```

### iOS 配置

可以创建不同的 Scheme 来对应不同环境，在 Xcode 中配置不同的 Bundle Identifier 和显示名称。

## 📝 最佳实践

1. **环境隔离**: 不同环境使用不同的API地址、数据库、第三方服务配置
2. **配置集中**: 所有环境相关配置集中在 `EnvironmentConfig` 中管理
3. **自动化构建**: 使用脚本自动化不同环境的构建流程
4. **环境标识**: 在非正式环境中显示明确的环境标识
5. **日志管理**: 正式环境关闭详细日志，开发环境启用完整日志
6. **安全性**: 敏感配置（如API密钥）不要直接写在代码中，使用环境变量

## 🐛 常见问题

### Q: 如何在运行时切换环境？
A: 环境配置在应用启动时确定，运行时无法切换。需要重新构建或重启应用。

### Q: 如何添加环境特定的配置？
A: 在 `EnvironmentConfig` 中添加新的配置项，然后在各个环境的静态配置中设置不同的值。

### Q: 构建时如何确保使用了正确的环境？
A: 使用提供的构建脚本，或在 `flutter build` 命令中明确指定 `--dart-define=ENVIRONMENT=xxx`。

### Q: 如何在 CI/CD 中使用？
A: 在 CI/CD 脚本中设置环境变量 `ENVIRONMENT`，或使用 `--dart-define` 参数指定环境。
