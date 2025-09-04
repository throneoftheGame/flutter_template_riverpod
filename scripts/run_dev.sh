#!/bin/bash

# Flutter 开发环境启动脚本

echo "🚀 Starting Flutter app in DEVELOPMENT environment..."

# 设置环境变量
export ENVIRONMENT=development

# 运行 Flutter 应用
flutter run \
  --dart-define=ENVIRONMENT=development \
  --target=lib/main.dart \
  --flavor=development \
  -t lib/main.dart

echo "✅ Development environment started"
