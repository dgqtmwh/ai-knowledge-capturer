#!/bin/bash
# ========================================================
# 知识捕手 (AI Knowledge Capturer) — 一键设置脚本
# ========================================================
# 用法：把这个项目拷到 Mac 上，终端运行：
#   chmod +x setup.sh && ./setup.sh
# ========================================================

set -e

echo "================================================"
echo "🧠 知识捕手 — 一键设置"
echo "================================================"

# 检查 Xcode
if ! xcode-select -p &>/dev/null; then
    echo "❌ 需要 Xcode！请先从 App Store 安装 Xcode 16+"
    echo "   安装完后重新运行此脚本"
    exit 1
fi
echo "✅ Xcode 已安装"

# 检查 XcodeGen
if ! command -v xcodegen &>/dev/null; then
    echo "📦 正在安装 XcodeGen..."
    if command -v brew &>/dev/null; then
        brew install xcodegen
    else
        echo "❌ 需要 Homebrew。安装命令："
        echo '   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        echo "   安装完后重新运行此脚本"
        exit 1
    fi
fi
echo "✅ XcodeGen 已安装"

# 获取 Team ID
TEAM_ID=$(security find-identity -v -p appleID 2>/dev/null | grep -oE '[A-Z0-9]{10}' | head -1)
if [ -z "$TEAM_ID" ]; then
    echo "⚠️  未检测到 Apple Developer Team ID"
    echo "   请在 project.yml 中手动设置 DEVELOPMENT_TEAM"
    echo "   或者稍后在 Xcode 中配置"
else
    # 替换 project.yml 中的 Team ID
    sed -i '' "s/DEVELOPMENT_TEAM: \"\"/DEVELOPMENT_TEAM: \"$TEAM_ID\"/" project.yml
    echo "✅ Team ID 已配置: $TEAM_ID"
fi

# 生成 Xcode 项目
echo "📐 正在生成 Xcode 项目..."
xcodegen generate
echo "✅ 项目已生成: AIKnowledgeCapturer.xcodeproj"

# 打开 Xcode
echo "🚀 正在打开 Xcode..."
open AIKnowledgeCapturer.xcodeproj

echo ""
echo "================================================"
echo "✅ 全部搞定！Xcode 已打开"
echo "================================================"
echo ""
echo "下一步："
echo "1. Xcode 中选目标设备（Simulator 或真机）"
echo "2. 按 Cmd+R 运行 🚀"
echo ""
echo "首次运行需要配置 App Group："
echo "  主 Target → Signing & Capabilities → + App Groups"
echo "  添加: group.com.yourname.aiknowledgecapturer"
echo "  Share Extension Target 同样操作"
echo ""
echo "有问题随时找我！"
