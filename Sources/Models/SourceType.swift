import Foundation

/// 来源类型 + 图标映射
enum SourceType: String, Codable, CaseIterable, Identifiable {
    case webpage = "网页"
    case screenshot = "截图"
    case note = "笔记"
    case link = "链接"
    case image = "图片"
    case text = "文本"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .webpage: return "safari"
        case .screenshot: return "photo.on.rectangle"
        case .note: return "note.text"
        case .link: return "link"
        case .image: return "photo"
        case .text: return "doc.text"
        }
    }
    
    var color: String {
        switch self {
        case .webpage: return "blue"
        case .screenshot: return "green"
        case .note: return "orange"
        case .link: return "purple"
        case .image: return "pink"
        case .text: return "gray"
        }
    }
}
