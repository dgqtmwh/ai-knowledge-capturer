#!/bin/bash
set -euo pipefail

echo "🚀 AI Knowledge Capturer - 一键 Mac 就绪脚本"
echo "============================================"

# 1. 检查 Xcode CLI tools
if ! xcode-select -p &>/dev/null; then
    echo "📦 安装 Xcode Command Line Tools..."
    xcode-select --install
    echo "   ⏳ 请等待安装完成，然后重新运行此脚本"
    exit 1
fi
echo "✅ Xcode CLI tools 已就绪"

# 2. 安装 XcodeGen（如果没有）
if ! command -v xcodegen &>/dev/null; then
    echo "📦 安装 XcodeGen..."
    if command -v brew &>/dev/null; then
        brew install xcodegen
    else
        echo "❌ 请先安装 Homebrew: https://brew.sh"
        exit 1
    fi
fi
echo "✅ XcodeGen 已就绪 (v$(xcodegen --version 2>/dev/null || echo 'installed'))"

# 3. 克隆项目
REPO_DIR="$HOME/projects/ai-knowledge-capturer"
if [ -d "$REPO_DIR" ]; then
    echo "📂 项目已存在，拉取最新代码..."
    cd "$REPO_DIR" && git pull
else
    echo "📂 克隆项目..."
    mkdir -p "$HOME/projects"
    git clone https://github.com/dgqtmwh/ai-knowledge-capturer.git "$REPO_DIR"
    cd "$REPO_DIR"
fi
echo "✅ 代码已就绪"

# 4. 生成 Xcode 项目
echo "🔧 生成 Xcode 项目..."
cd "$REPO_DIR"
xcodegen generate
echo "✅ Xcode 项目已生成"

# 5. 打开 Xcode
echo "📱 打开 Xcode..."
open AIKnowledgeCapturer.xcodeproj

echo ""
echo "🎉 完成！Xcode 已打开，选 iOS 18+ Simulator → Cmd+R 运行即可"
echo "============================================"
