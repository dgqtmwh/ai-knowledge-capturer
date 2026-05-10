import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleSharedContent()
    }
    
    private func handleSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            complete()
            return
        }
        
        // 尝试获取 URL
        if attachments.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            loadURL(from: attachments)
            return
        }
        
        // 尝试获取文本
        if attachments.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) {
            loadText(from: attachments)
            return
        }
        
        // 尝试获取图片
        if attachments.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
            loadImage(from: attachments)
            return
        }
        
        complete()
    }
    
    private func loadURL(from attachments: [NSItemProvider]) {
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
                guard let url = item as? URL else {
                    self?.loadTitleThenComplete(from: attachments, url: nil)
                    return
                }
                self?.loadTitleThenComplete(from: attachments, url: url)
            }
            return
        }
    }
    
    private func loadTitleThenComplete(from attachments: [NSItemProvider], url: URL?) {
        // 尝试获取标题
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (item, error) in
                let title = item as? String ?? url?.absoluteString ?? "未命名"
                let text = item as? String
                
                let shared = SharedContent(
                    title: String(title.prefix(200)),
                    url: url?.absoluteString,
                    text: text ?? url?.absoluteString,
                    sourceType: url != nil ? "网页" : "文本"
                )
                AppGroup.saveSharedContent(shared)
                self?.complete()
            }
            return
        }
        
        // 没有文本，用 URL 当标题
        let shared = SharedContent(
            title: url?.absoluteString ?? "未命名",
            url: url?.absoluteString,
            sourceType: "链接"
        )
        AppGroup.saveSharedContent(shared)
        complete()
    }
    
    private func loadText(from attachments: [NSItemProvider]) {
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (item, error) in
                let text = item as? String ?? ""
                let title = String(text.prefix(100))
                
                let shared = SharedContent(
                    title: title,
                    text: text,
                    sourceType: "文本"
                )
                AppGroup.saveSharedContent(shared)
                self?.complete()
            }
            return
        }
    }
    
    private func loadImage(from attachments: [NSItemProvider]) {
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] (item, error) in
                let imageData: Data?
                if let url = item as? URL {
                    imageData = try? Data(contentsOf: url)
                } else if let image = item as? UIImage {
                    imageData = image.jpegData(compressionQuality: 0.8)
                } else {
                    imageData = nil
                }
                
                let shared = SharedContent(
                    title: "截图 \(Date().formatted(date: .omitted, time: .shortened))",
                    imageData: imageData,
                    sourceType: "截图"
                )
                AppGroup.saveSharedContent(shared)
                self?.complete()
            }
            return
        }
    }
    
    private func complete() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: nil)
        }
    }
}
