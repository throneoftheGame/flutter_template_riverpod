# Flutter Template Riverpod - Makefile
# 简化常用开发操作

.PHONY: help i18n clean build run test

# 默认目标
help:
	@echo "Flutter Template Riverpod - 可用命令:"
	@echo ""
	@echo "  make i18n     - 构建国际化文件"
	@echo "  make clean    - 清理项目"
	@echo "  make build    - 构建项目"
	@echo "  make run      - 运行项目"
	@echo "  make test     - 运行测试"
	@echo "  make setup    - 初始化项目"
	@echo ""

# 构建国际化文件
i18n:
	@echo "🌍 构建国际化文件..."
	@./scripts/build_i18n.sh

# 清理项目
clean:
	@echo "🧹 清理项目..."
	@flutter clean
	@flutter pub get

# 构建项目
build:
	@echo "🔨 构建项目..."
	@flutter build apk --release

# 运行项目
run:
	@echo "🚀 运行项目..."
	@flutter run

# 运行测试
test:
	@echo "🧪 运行测试..."
	@flutter test

# 初始化项目
setup:
	@echo "⚙️ 初始化项目..."
	@flutter pub get
	@make i18n
	@echo "✅ 项目初始化完成！"

# 开发模式（监听文件变化）
dev:
	@echo "👨‍💻 启动开发模式..."
	@flutter run --hot

# 生成代码
generate:
	@echo "🔄 生成代码..."
	@dart run build_runner build --delete-conflicting-outputs

# 完整构建流程
full-build: clean i18n generate build
	@echo "✅ 完整构建完成！"

