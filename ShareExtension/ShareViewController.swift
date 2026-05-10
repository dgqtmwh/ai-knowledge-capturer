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
        
        let attachmentList = attachments // 创建不可变副本
        
        if attachmentList.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            loadURL(from: attachmentList)
            return
        }
        
        if attachmentList.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) {
            loadText(from: attachmentList)
            return
        }
        
        if attachmentList.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
            loadImage(from: attachmentList)
            return
        }
        
        complete()
    }
    
    private func loadURL(from attachments: [NSItemProvider]) {
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
                guard let url = item as? URL else {
                    self?.complete()
                    return
                }
                
                // 尝试获取标题文本
                for textProvider in attachments where textProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
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
                    return
                }
                
                // 没有文本，用URL
                let shared = SharedContent(
                    title: url.absoluteString,
                    url: url.absoluteString,
                    sourceType: "链接"
                )
                AppGroup.saveSharedContent(shared)
                self?.complete()
            }
            return
        }
    }
    
    private func loadText(from attachments: [NSItemProvider]) {
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
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
