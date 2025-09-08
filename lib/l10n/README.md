# 模块化国际化系统

## 📁 文件结构

```
lib/l10n/
├── modules/                    # 模块化源文件（开发者编辑）
│   ├── common/                # 通用模块
│   │   ├── common_en.arb     # 英文通用字符串
│   │   └── common_zh.arb     # 中文通用字符串
│   ├── auth/                 # 认证模块
│   │   ├── auth_en.arb       # 英文认证字符串
│   │   └── auth_zh.arb       # 中文认证字符串
│   ├── home/                 # 首页模块
│   │   ├── home_en.arb       # 英文首页字符串
│   │   └── home_zh.arb       # 中文首页字符串
│   └── settings/             # 设置模块
│       ├── settings_en.arb   # 英文设置字符串
│       └── settings_zh.arb   # 中文设置字符串
├── generated/                 # 自动生成的合并文件（不要手动编辑）
│   ├── app_en.arb            # 合并后的英文文件
│   └── app_zh.arb            # 合并后的中文文件
├── build_i18n.dart          # 构建脚本
└── README.md                 # 本文档
```

## 🚀 使用方法

### 1. 添加新的国际化字符串

**只需要编辑对应模块的文件：**

```bash
# 为认证模块添加新字符串
vim lib/l10n/modules/auth/auth_en.arb
vim lib/l10n/modules/auth/auth_zh.arb

# 为首页模块添加新字符串
vim lib/l10n/modules/home/home_en.arb
vim lib/l10n/modules/home/home_zh.arb
```

### 2. 构建国际化文件

```bash
# 方法1：使用便捷脚本
./scripts/build_i18n.sh

# 方法2：手动执行
dart run lib/l10n/build_i18n.dart
flutter gen-l10n
```

### 3. 在代码中使用

```dart
// 使用方式完全不变
Text(AppLocalizations.of(context)!.login)           // 来自 auth 模块
Text(AppLocalizations.of(context)!.welcome)         // 来自 home 模块
Text(AppLocalizations.of(context)!.settings)        // 来自 settings 模块
Text(AppLocalizations.of(context)!.confirm)         // 来自 common 模块
```

## 🎯 优势

### 1. 团队协作友好
- ✅ 每个开发者只需维护自己模块的文件
- ✅ 大大减少 Git 冲突
- ✅ 职责清晰，易于维护

### 2. 模块化管理
- ✅ 按功能模块组织国际化字符串
- ✅ 便于查找和维护
- ✅ 支持模块级复用

### 3. 自动化构建
- ✅ 自动合并所有模块文件
- ✅ 自动检测键冲突
- ✅ 一键构建整个国际化系统

## 🔧 开发流程

### 日常开发
1. 在对应模块的 ARB 文件中添加字符串
2. 运行 `./scripts/build_i18n.sh` 构建
3. 在代码中使用新的国际化字符串

### 添加新模块
1. 在 `lib/l10n/modules/` 下创建新模块目录
2. 创建对应的 `module_en.arb` 和 `module_zh.arb` 文件
3. 运行构建脚本，系统会自动扫描新模块

### Git 工作流
```bash
# 只需要提交模块文件和构建脚本
git add lib/l10n/modules/
git add lib/l10n/build_i18n.dart
git add scripts/build_i18n.sh

# 可选：也可以提交生成的文件（推荐）
git add lib/l10n/generated/
```

## 📝 模块分类指南

### common (通用)
- 按钮文本：确定、取消、保存等
- 通用消息：加载中、操作成功等
- 语言切换相关

### auth (认证)
- 登录、注册相关
- 密码、验证相关
- 账号管理相关

### home (首页)
- 欢迎信息
- 功能演示
- 快捷操作

### settings (设置)
- 设置页面相关
- 主题、语言设置
- 偏好设置

## ⚠️ 注意事项

1. **不要手动编辑 `generated/` 目录下的文件**
2. **提交前记得运行构建脚本**
3. **注意避免不同模块间的键名冲突**
4. **保持模块文件的 JSON 格式正确**

## 🛠️ 故障排除

### 构建失败
```bash
# 检查 JSON 格式
dart run lib/l10n/build_i18n.dart

# 重新生成 Flutter 代码
flutter gen-l10n
```

### 键冲突
构建脚本会自动检测并警告键冲突，请检查相关模块文件。

### 新字符串不生效
确保运行了构建脚本并重新启动了应用。

