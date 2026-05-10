import Foundation
import SwiftData

/// AI 自动生成的标签
struct AITag: Codable, Hashable {
    let name: String
    let confidence: Float // 0-1
}

/// 核心数据模型 — 一条被保存的知识
@Model
final class SavedItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var url: String?
    var originalText: String?
    var summary: String?
    var category: String?
    var tagsData: Data? // 编码后的 [AITag]
    var sourceTypeRaw: String
    var createdAt: Date
    var updatedAt: Date
    var lastAccessedAt: Date?
    var isFavorited: Bool
    var accessCount: Int
    
    // 计算属性
    var sourceType: SourceType {
        get { SourceType(rawValue: sourceTypeRaw) ?? .text }
        set { sourceTypeRaw = newValue.rawValue }
    }
    
    var tags: [AITag] {
        get {
            guard let data = tagsData else { return [] }
            return (try? JSONDecoder().decode([AITag].self, from: data)) ?? []
        }
        set {
            tagsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(
        title: String,
        url: String? = nil,
        originalText: String? = nil,
        sourceType: SourceType = .text
    ) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.originalText = originalText
        self.sourceTypeRaw = sourceType.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorited = false
        self.accessCount = 0
    }
}

/// 免费层限制
struct FreeTierLimits {
    static let maxSavedItems = 50
    static let maxItemsForSearch = 50
}
