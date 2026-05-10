import UIKit
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
        
        if attachments.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            loadURL(from: attachments)
            return
        }
        
        if attachments.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) {
            loadText(from: attachments)
            return
        }
        
        if attachments.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
            loadImage(from: attachments)
            return
        }
        
        complete()
    }
    
    private func loadURL(from attachments: [NSItemProvider]) {
        guard let provider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) else {
            complete()
            return
        }
        
        provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
            guard let url = item as? URL else {
                self?.complete()
                return
            }
            
            // 找标题文本
            if let textProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) {
                textProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (textItem, _) in
                    let title = textItem as? String ?? url.absoluteString
                    let text = textItem as? String
                    let shared = SharedContent(
                        title: String(title.prefix(200)),
                        url: url.absoluteString,
                        text: text ?? url.absoluteString,
                        sourceType: "网页"
                    )
                    AppGroup.saveSharedContent(shared)
                    self?.complete()
                }
            } else {
                let shared = SharedContent(
                    title: url.absoluteString,
                    url: url.absoluteString,
                    sourceType: "链接"
                )
                AppGroup.saveSharedContent(shared)
                self?.complete()
            }
        }
    }
    
    private func loadText(from attachments: [NSItemProvider]) {
        guard let provider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) else {
            complete()
            return
        }
        
        provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (item, error) in
            let text = item as? String ?? ""
            let shared = SharedContent(
                title: String(text.prefix(100)),
                text: text,
                sourceType: "文本"
            )
            AppGroup.saveSharedContent(shared)
            self?.complete()
        }
    }
    
    private func loadImage(from attachments: [NSItemProvider]) {
        guard let provider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) else {
            complete()
            return
        }
        
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
    }
    
    private func complete() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: nil)
        }
    }
}
