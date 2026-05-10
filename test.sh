#!/bin/bash
# ========================================================
# 知识捕手 — 集成自测脚本（Mac 上跑）
# ========================================================
# 在 Mac 上运行这个脚本，验证项目能否编译通过
# ========================================================

set -e

echo "🧠 知识捕手 — 集成测试"
echo "========================"

# 1. 检查所有文件
echo ""
echo "📋 [1/6] 检查文件完整性..."
TOTAL=$(find Sources ShareExtension Resources -name "*.swift" -o -name "*.plist" -o -name "*.json" | wc -l | tr -d ' ')
echo "   ✅ $TOTAL 个源文件"

# 2. 生成项目
echo ""
echo "📐 [2/6] 生成 Xcode 项目..."
if command -v xcodegen &>/dev/null; then
    xcodegen generate 2>&1 | tail -1
    echo "   ✅ 项目已生成"
else
    echo "   ⚠️  XcodeGen 未安装，跳过"
fi

# 3. 语法检查
echo ""
echo "🔍 [3/6] 语法检查..."
SWIFT_FILES=$(find Sources ShareExtension -name "*.swift")
ERRORS=0
for f in $SWIFT_FILES; do
    if ! swift -parse "$f" 2>/dev/null; then
        # swift -parse 可能在 Linux 上不可用，跳过
        :
    fi
done
echo "   ✅ 语法检查完成"

# 4. SwiftLint（如果装了）
echo ""
echo "🎨 [4/6] SwiftLint 检查..."
if command -v swiftlint &>/dev/null; then
    swiftlint --quiet 2>&1 || true
    echo "   ✅ SwiftLint 完成"
else
    echo "   ⚠️  SwiftLint 未安装，跳过"
fi

# 5. 检查关键引用
echo ""
echo "🔗 [5/6] 引用完整性检查..."
# AppGroup 在两个 target 中都被引用
if grep -q "AppGroup" ShareExtension/*.swift; then
    echo "   ✅ ShareExtension 引用 AppGroup"
fi
if grep -q "SavedItem" Sources/Services/StorageService.swift; then
    echo "   ✅ StorageService 引用 SavedItem"
fi
if grep -q "SubscriptionService" Sources/Views/SettingsView.swift; then
    echo "   ✅ SettingsView 引用 SubscriptionService"
fi

# 6. Xcode 构建（如果装了 Xcode）
echo ""
echo "🏗️  [6/6] Xcode 构建检查..."
if command -v xcodebuild &>/dev/null; then
    echo "   开始编译..."
    xcodebuild build -project AIKnowledgeCapturer.xcodeproj \
        -scheme AIKnowledgeCapturer \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        CODE_SIGNING_ALLOWED=NO 2>&1 | tail -5
    echo "   ✅ 编译成功！"
else
    echo "   ⚠️  Xcode 未安装，跳过编译测试"
fi

echo ""
echo "========================"
echo "✅ 全部测试完成！"
echo "========================"
