#!/bin/bash

# Flutter Template 项目初始化脚本
echo "🚀 开始初始化 Flutter Template 项目..."

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter SDK"
    exit 1
fi

# 检查 Flutter 版本
flutter --version

echo "📦 安装项目依赖..."
flutter pub get

echo "🔧 生成代码..."
dart run build_runner build --delete-conflicting-outputs

echo "🧪 运行测试..."
flutter test

echo "📊 代码分析..."
flutter analyze

echo "✅ 项目初始化完成！"
echo ""
echo "🎯 接下来你可以："
echo "  • 运行项目: flutter run"
echo "  • 生成代码: dart run build_runner watch"
echo "  • 查看文档: 阅读 README.md 和 DEVELOPMENT.md"
echo ""
echo "🎉 开始你的 Flutter 开发之旅吧！"
