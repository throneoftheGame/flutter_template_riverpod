# 更新日志

本文件记录了项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2024-01-20

### 🎉 初始版本

#### 新增

- **核心架构**

  - 基于 Clean Architecture 的项目结构
  - Feature-based 代码组织方式
  - 完整的错误处理机制
  - 统一的结果类型封装

- **状态管理**

  - 集成 Riverpod 2.5.1 状态管理
  - 主题模式状态管理（浅色/深色/跟随系统）
  - 语言切换状态管理（中英文）
  - 自定义 Riverpod 观察者用于调试

- **网络层**

  - Dio 5.9.0 HTTP 客户端配置
  - 认证拦截器自动添加 Token
  - 错误处理拦截器统一异常处理
  - Talker 日志拦截器记录网络请求
  - 完整的网络异常分类处理

- **存储层**

  - SharedPreferences 存储服务封装
  - 支持基础数据类型和对象存储
  - 统一的存储接口抽象
  - 完整的错误处理和日志记录

- **UI 组件库**

  - 加载组件（Loading、SmallLoading、LoadingOverlay）
  - 错误显示组件（AppErrorWidget、SimpleErrorWidget）
  - 空状态组件（EmptyWidget、SearchEmptyWidget、NetworkEmptyWidget）
  - 扩展方法（String、BuildContext 扩展）

- **示例页面**

  - 首页 - 展示各种功能和组件
  - 登录页 - 完整的表单验证和登录流程
  - 设置页 - 主题切换、语言切换、各种设置项

- **开发工具**

  - 基于 Talker 的日志系统
  - 代码生成配置（build_runner）
  - Flutter Lints 代码规范检查
  - 完整的依赖配置

- **国际化**

  - 中英文双语支持
  - 动态语言切换
  - 本地化字符串管理

- **主题系统**
  - Material Design 3 主题
  - 浅色/深色主题支持
  - 跟随系统主题模式
  - 动态主题切换

#### 技术栈

- Flutter SDK: >= 3.8.0
- Dart SDK: >= 3.8.0
- 状态管理: flutter_riverpod ^2.5.1
- 网络请求: dio ^5.9.0
- 本地存储: shared_preferences ^2.5.3
- 日志系统: talker_flutter ^5.0.0
- UI 组件: google_fonts ^6.3.1, flutter_spinkit ^5.2.2
- 代码生成: riverpod_generator ^2.4.3, build_runner ^2.4.14

#### 文档

- 完整的 README.md 说明文档
- 项目结构说明
- 使用指南和示例代码
- 常见问题解答
- 贡献指南

---

## 版本说明

### 版本号格式

- **主版本号**: 不兼容的 API 修改
- **次版本号**: 向下兼容的功能性新增
- **修订号**: 向下兼容的问题修正

### 变更类型

- `新增` - 新功能
- `变更` - 对现有功能的变更
- `弃用` - 即将移除的功能
- `移除` - 已移除的功能
- `修复` - 问题修复
- `安全` - 安全相关修复
