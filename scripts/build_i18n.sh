#!/bin/bash

# 国际化构建脚本
# 用法: ./scripts/build_i18n.sh

echo "🌍 开始构建国际化文件..."

# 运行合并脚本
dart run lib/l10n/build_i18n.dart

if [ $? -eq 0 ]; then
    echo "🔄 重新生成 Flutter 国际化代码..."
    flutter gen-l10n
    
    if [ $? -eq 0 ]; then
        echo "✅ 国际化构建完成！"
        echo ""
        echo "📁 文件结构："
        echo "├── lib/l10n/modules/     # 模块化源文件"
        echo "├── lib/l10n/generated/   # 自动生成的合并文件"
        echo "└── lib/l10n/            # Flutter 生成的代码"
        echo ""
        echo "💡 提示："
        echo "- 只需要编辑 modules/ 目录下的文件"
        echo "- generated/ 目录的文件会自动生成，不要手动编辑"
        echo "- 提交代码前记得运行此脚本"
    else
        echo "❌ Flutter 国际化代码生成失败"
        exit 1
    fi
else
    echo "❌ 国际化文件合并失败"
    exit 1
fi

