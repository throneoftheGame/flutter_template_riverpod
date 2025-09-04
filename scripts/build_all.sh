#!/bin/bash

# Flutter 全环境构建脚本

echo "🔨 Building Flutter app for all environments..."

# 创建构建输出目录
mkdir -p build/outputs

# 开发环境构建
echo "📱 Building Development APK..."
flutter build apk \
  --dart-define=ENVIRONMENT=development \
  --target=lib/main.dart \
  --flavor=development \
  --debug \
  --build-name=1.0.0-dev \
  --build-number=1

# 重命名开发版本
mv build/app/outputs/flutter-apk/app-development-debug.apk build/outputs/app-development-debug.apk 2>/dev/null || true
mv build/app/outputs/flutter-apk/app-debug.apk build/outputs/app-development-debug.apk 2>/dev/null || true

# 灰度环境构建
echo "🧪 Building Staging APK..."
flutter build apk \
  --dart-define=ENVIRONMENT=staging \
  --target=lib/main.dart \
  --flavor=staging \
  --profile \
  --build-name=1.0.0-staging \
  --build-number=1

# 重命名灰度版本
mv build/app/outputs/flutter-apk/app-staging-profile.apk build/outputs/app-staging-profile.apk 2>/dev/null || true
mv build/app/outputs/flutter-apk/app-profile.apk build/outputs/app-staging-profile.apk 2>/dev/null || true

# 正式环境构建
echo "🌟 Building Production APK..."
flutter build apk \
  --dart-define=ENVIRONMENT=production \
  --target=lib/main.dart \
  --flavor=production \
  --release \
  --build-name=1.0.0 \
  --build-number=1

# 重命名正式版本
mv build/app/outputs/flutter-apk/app-production-release.apk build/outputs/app-production-release.apk 2>/dev/null || true
mv build/app/outputs/flutter-apk/app-release.apk build/outputs/app-production-release.apk 2>/dev/null || true

echo "✅ All builds completed! Check build/outputs/ directory"
ls -la build/outputs/
