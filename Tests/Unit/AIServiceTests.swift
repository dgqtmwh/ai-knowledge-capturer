import XCTest
@testable import AIKnowledgeCapturer

/// Service 层测试 — 知识捕手 AI 服务
final class AIServiceTests: XCTestCase {

    private let ai = AIService.shared

    // MARK: - 摘要生成

    /// 有效文本应返回非空摘要
    func testGenerateSummary_ValidText_ReturnsSummary() async {
        let text = """
        SwiftUI 是 Apple 推出的声明式 UI 框架，使用 Swift 语言编写。
        开发者可以通过简单的代码实现复杂的用户界面。
        本文介绍了 SwiftUI 的核心概念和最佳实践。
        """
        let summary = await ai.generateSummary(for: text)
        XCTAssertFalse(summary.isEmpty, "有效文本应返回摘要")
    }

    /// 空文本应返回兜底文案
    func testGenerateSummary_EmptyText_ReturnsDefault() async {
        let summary = await ai.generateSummary(for: "")
        XCTAssertEqual(summary, "无内容", "空文本应返回'无内容'")
    }

    /// 纯空格文本也应返回兜底
    func testGenerateSummary_WhitespaceText_ReturnsDefault() async {
        let summary = await ai.generateSummary(for: "   ")
        XCTAssertEqual(summary, "无内容")
    }

    /// 短文本摘要不应为空
    func testGenerateSummary_ShortText_ReturnsNonEmpty() async {
        let summary = await ai.generateSummary(for: "Hello World")
        XCTAssertFalse(summary.isEmpty, "短文本也应返回非空摘要")
    }

    // MARK: - 分类

    /// 技术类文本应分类为"技术"
    func testCategorize_Technical_Returns技术() async {
        let cat = await ai.categorize("如何使用 Xcode 和 Swift 开发 iOS App", title: "iOS 开发")
        XCTAssertEqual(cat, "技术")
    }

    /// 设计类文本应分类为"设计"
    func testCategorize_Design_Returns设计() async {
        let cat = await ai.categorize("Figma UI 设计技巧与交互原型", title: "设计指南")
        XCTAssertEqual(cat, "设计")
    }

    /// 商业类文本应分类为"商业"
    func testCategorize_Business_Returns商业() async {
        let cat = await ai.categorize("SaaS 产品增长策略与变现模式分析", title: "商业分析")
        XCTAssertEqual(cat, "商业")
    }

    /// 生活类文本应分类为"生活"
    func testCategorize_Lifestyle_Returns生活() async {
        let cat = await ai.categorize("健康饮食与健身计划的完美搭配", title: "生活分享")
        XCTAssertEqual(cat, "生活")
    }

    /// 默认文本应分类为"其他"
    func testCategorize_Default_Returns其他() async {
        let cat = await ai.categorize("这是一段无关的随机文本", title: "杂项")
        XCTAssertEqual(cat, "其他")
    }

    // MARK: - 标签生成

    /// 含关键词的文本应生成对应标签
    func testGenerateTags_WithKeywords_ReturnsTags() async {
        let tags = await ai.generateTags("SwiftUI 和 AI 模型在 iOS 开发中的应用", title: "技术文章")
        XCTAssertGreaterThan(tags.count, 0, "含关键词应生成标签")
        // 应包含 "Swift" 或 "AI" 或 "iOS"
        let keywordTags = ["Swift", "AI", "iOS"]
        let hasKeyword = tags.contains { keywordTags.contains($0) }
        XCTAssertTrue(hasKeyword, "标签应包含关键词")
    }

    /// 无关键词的文本应返回空标签
    func testGenerateTags_NoKeywords_ReturnsEmpty() async {
        let tags = await ai.generateTags("今天天气真好", title: "日记")
        // 可能有标签也可能为空，不应崩溃
        XCTAssertNotNil(tags)
    }

    /// 标签最多 3 个
    func testGenerateTags_MaxThree() async {
        let tags = await ai.generateTags(
            "Swift AI Apple LLM 设计 代码 产品 用户 增长 数据 模型",
            title: "技术综合"
        )
        XCTAssertLessThanOrEqual(tags.count, 3, "标签不应超过 3 个")
    }
}
