#!/bin/bash

# Flutter 正式环境启动脚本

echo "🌟 Starting Flutter app in PRODUCTION environment..."

# 设置环境变量
export ENVIRONMENT=production

# 构建 Flutter 应用（正式环境通常是构建而不是运行）
flutter build apk \
  --dart-define=ENVIRONMENT=production \
  --target=lib/main.dart \
  --release

echo "✅ Production build completed"
