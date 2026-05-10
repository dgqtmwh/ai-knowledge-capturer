import SwiftUI

@main
struct AIKnowledgeCapturerApp: App {
    @State private var isReady = false
    
    var body: some Scene {
        WindowGroup {
            if isReady {
                ContentView()
                    .task {
                        await SubscriptionService.shared.loadProducts()
                    }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    Text("知识捕手")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    ProgressView()
                    Text("正在准备你的第二大脑...")
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    setupApp()
                }
            }
        }
    }
    
    private func setupApp() {
        StorageService.shared.setup()
        
        // 检查并导入 Share Extension 的内容
        StorageService.shared.importSharedContent()
        
        // 标记就绪
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isReady = true
        }
    }
}
