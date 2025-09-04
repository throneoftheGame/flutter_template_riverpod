#!/bin/bash

# Flutter 灰度环境启动脚本

echo "🧪 Starting Flutter app in STAGING environment..."

# 设置环境变量
export ENVIRONMENT=staging

# 运行 Flutter 应用
flutter run \
  --dart-define=ENVIRONMENT=staging \
  --target=lib/main.dart \
  --flavor=staging \
  -t lib/main.dart

echo "✅ Staging environment started"
