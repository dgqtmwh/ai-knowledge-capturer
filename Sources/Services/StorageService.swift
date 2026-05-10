import Foundation
import SwiftData

/// 数据存储服务 — 基于 SwiftData
@MainActor
final class StorageService {
    static let shared = StorageService()
    
    private var container: ModelContainer?
    private var context: ModelContext?
    
    var isReady: Bool { container != nil }
    
    func setup() {
        let schema = Schema([SavedItem.self])
        let config = ModelConfiguration(
            schema: schema,
            url: AppGroup.storePath,
            groupContainer: .identifier(AppGroup.identifier)
        )
        container = try? ModelContainer(for: schema, configurations: config)
        context = container?.mainContext
    }
    
    // MARK: - CRUD
    
    func save(_ item: SavedItem) {
        context?.insert(item)
        try? context?.save()
    }
    
    func delete(_ item: SavedItem) {
        context?.delete(item)
        try? context?.save()
    }
    
    func update() {
        try? context?.save()
    }
    
    func fetchAll() -> [SavedItem] {
        let descriptor = FetchDescriptor<SavedItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context?.fetch(descriptor)) ?? []
    }
    
    func fetchRecent(limit: Int = 20) -> [SavedItem] {
        var descriptor = FetchDescriptor<SavedItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context?.fetch(descriptor)) ?? []
    }
    
    func search(query: String) -> [SavedItem] {
        let descriptor = FetchDescriptor<SavedItem>(
            predicate: #Predicate { item in
                item.title.localizedStandardContains(query) ||
                (item.summary?.localizedStandardContains(query) ?? false) ||
                (item.category?.localizedStandardContains(query) ?? false)
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context?.fetch(descriptor)) ?? []
    }
    
    func fetchByCategory(_ category: String) -> [SavedItem] {
        let descriptor = FetchDescriptor<SavedItem>(
            predicate: #Predicate { item in
                item.category == category
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context?.fetch(descriptor)) ?? []
    }
    
    /// 导入 Share Extension 传来的内容
    func importSharedContent() -> Int {
        let items = AppGroup.loadSharedContents()
        guard !items.isEmpty else { return 0 }
        
        for shared in items {
            let item = SavedItem(
                title: shared.title,
                url: shared.url,
                originalText: shared.text,
                sourceType: SourceType(rawValue: shared.sourceType) ?? .text
            )
            save(item)
        }
        
        AppGroup.clearSharedContents()
        return items.count
    }
    
    var itemCount: Int {
        let descriptor = FetchDescriptor<SavedItem>()
        return (try? context?.fetchCount(descriptor)) ?? 0
    }
}
