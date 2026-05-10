import Foundation

/// App Group 配置 — 主 App 与 Share Extension 共享数据
enum AppGroup {
    static let identifier = "group.com.yourname.aiknowledgecapturer"
    
    static var containerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)!
    }
    
    static var storePath: URL {
        containerURL.appendingPathComponent("data.store")
    }
    
    /// 从 Share Extension 传递内容到主 App
    static func saveSharedContent(_ content: SharedContent) {
        var items = loadSharedContents()
        items.append(content)
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults(suiteName: identifier)?.set(data, forKey: "shared_contents")
        }
    }
    
    static func loadSharedContents() -> [SharedContent] {
        guard let data = UserDefaults(suiteName: identifier)?.data(forKey: "shared_contents"),
              let items = try? JSONDecoder().decode([SharedContent].self, from: data)
        else { return [] }
        return items
    }
    
    static func clearSharedContents() {
        UserDefaults(suiteName: identifier)?.removeObject(forKey: "shared_contents")
    }
}

/// Share Extension → 主App 的中间传输结构
struct SharedContent: Codable {
    let id: UUID
    let title: String
    let url: String?
    let text: String?
    let imageData: Data?
    let sourceType: String
    let sharedAt: Date
    
    init(title: String, url: String? = nil, text: String? = nil, imageData: Data? = nil, sourceType: String = "text") {
        self.id = UUID()
        self.title = title
        self.url = url
        self.text = text
        self.imageData = imageData
        self.sourceType = sourceType
        self.sharedAt = Date()
    }
}
