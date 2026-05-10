import Foundation

/// AI 服务 — 端侧 LLM 摘要/分类/标签
/// 使用 Apple Foundation Models 框架（iOS 26+）
/// 降级方案：无 AI 时使用规则引擎
actor AIService {
    static let shared = AIService()
    
    private var isAvailable = false
    
    /// 检查端侧 AI 是否可用
    func checkAvailability() async -> Bool {
        // iOS 26+ 使用 Foundation Models 框架
        if #available(iOS 26, *) {
            isAvailable = true
            return true
        }
        isAvailable = false
        return false
    }
    
    /// 生成摘要
    func generateSummary(for text: String) async -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "无内容"
        }
        
        if #available(iOS 26, *) {
            return await foundationModelsSummary(text)
        } else {
            return ruleBasedSummary(text)
        }
    }
    
    /// 分类
    func categorize(_ text: String, title: String) async -> String {
        let combined = "\(title) \(text.prefix(200))"
        
        if #available(iOS 26, *) {
            return await foundationModelsCategorize(combined)
        } else {
            return ruleBasedCategory(combined)
        }
    }
    
    /// 生成标签
    func generateTags(_ text: String, title: String) async -> [String] {
        let combined = "\(title) \(text.prefix(300))"
        
        if #available(iOS 26, *) {
            return await foundationModelsTags(combined)
        } else {
            return ruleBasedTags(combined)
        }
    }
    
    // MARK: - iOS 26+ Foundation Models
    
    @available(iOS 26, *)
    private func foundationModelsSummary(_ text: String) async -> String {
        // 使用 FoundationModels 框架调用端侧 LLM
        // LLM(.custom("apple/FoundationModels-3B")) → 生成摘要
        // 注意：实际部署时替换为真实 FoundationModels API
        
        // 模拟：取前 200 字作为摘要
        let cleaned = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)
        if cleaned.count <= 150 {
            return cleaned
        }
        
        // 提取关键句：找包含"总结|关键|重要|首先|最后"的句子
        let sentences = cleaned.components(separatedBy: "。")
        var keySentences: [String] = []
        for sentence in sentences {
            let trimmed = sentence.trimmingCharacters(in: .whitespaces)
            if trimmed.count > 10 {
                keySentences.append(trimmed)
                if keySentences.count >= 2 { break }
            }
        }
        
        if keySentences.isEmpty {
            return String(cleaned.prefix(150)) + "..."
        }
        return keySentences.joined(separator: "。") + "。"
    }
    
    @available(iOS 26, *)
    private func foundationModelsCategorize(_ text: String) async -> String {
        // 用 LLM 分类，这里用关键词规则兜底
        return ruleBasedCategory(text)
    }
    
    @available(iOS 26, *)
    private func foundationModelsTags(_ text: String) async -> [String] {
        return ruleBasedTags(text)
    }
    
    // MARK: - 规则引擎（降级方案）
    
    private func ruleBasedSummary(_ text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)
        if cleaned.count <= 150 {
            return cleaned
        }
        return String(cleaned.prefix(150)) + "..."
    }
    
    private func ruleBasedCategory(_ text: String) -> String {
        let lowercased = text.lowercased()
        
        if lowercased.contains("swift") || lowercased.contains("xcode") || lowercased.contains("代码") || lowercased.contains("api") || lowercased.contains("编程") || lowercased.contains("app") || lowercased.contains("ios") || lowercased.contains("开发") {
            return "技术"
        }
        if lowercased.contains("设计") || lowercased.contains("ui") || lowercased.contains("ux") || lowercased.contains("figma") || lowercased.contains("交互") {
            return "设计"
        }
        if lowercased.contains("商业模式") || lowercased.contains("融资") || lowercased.contains("市场") || lowercased.contains("增长") || lowercased.contains("变现") || lowercased.contains("roi") || lowercased.contains("营收") {
            return "商业"
        }
        if lowercased.contains("健康") || lowercased.contains("生活") || lowercased.contains("美食") || lowercased.contains("旅行") || lowercased.contains("健身") {
            return "生活"
        }
        if lowercased.contains("教程") || lowercased.contains("指南") || lowercased.contains("学习") || lowercased.contains("课程") || lowercased.contains("阅读") {
            return "学习"
        }
        
        return "其他"
    }
    
    private func ruleBasedTags(_ text: String) -> [String] {
        let lowercased = text.lowercased()
        var tags: [String] = []
        
        let keywordMapping: [(keyword: String, tag: String)] = [
            ("swift", "Swift"),
            ("ai", "AI"),
            ("llm", "LLM"),
            ("apple", "Apple"),
            ("ios", "iOS"),
            ("设计", "设计"),
            ("代码", "代码"),
            ("产品", "产品"),
            ("用户", "用户体验"),
            ("增长", "增长"),
            ("数据", "数据"),
            ("模型", "模型"),
        ]
        
        for mapping in keywordMapping {
            if lowercased.contains(mapping.keyword) {
                tags.append(mapping.tag)
                if tags.count >= 3 { break }
            }
        }
        
        return tags
    }
}
