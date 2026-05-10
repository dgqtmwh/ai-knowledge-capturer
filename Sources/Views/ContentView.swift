import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ContentListView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showSettings = true }) {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
            }
            .tabItem {
                Label("收藏", systemImage: "tray.full")
            }
            .tag(0)
            
            NavigationStack {
                SearchView(viewModel: viewModel)
            }
            .tabItem {
                Label("搜索", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("设置", systemImage: "gearshape")
            }
            .tag(2)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
}

@MainActor
class ContentViewModel: ObservableObject {
    @Published var items: [SavedItem] = []
    @Published var selectedCategory: String? = nil
    @Published var searchText = ""
    @Published var isLoading = false
    
    private let storage = StorageService.shared
    private let aiService = AIService.shared
    
    var categories: [String] {
        let cats = Set(items.compactMap { $0.category })
        return ["全部"] + cats.sorted()
    }
    
    var filteredItems: [SavedItem] {
        var result = items
        if let cat = selectedCategory, cat != "全部" {
            result = result.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedStandardContains(searchText) ||
                ($0.summary ?? "").localizedStandardContains(searchText)
            }
        }
        return result
    }
    
    var isPro: Bool {
        SubscriptionService.shared.isPro
    }
    
    var canAddMore: Bool {
        isPro || items.count < FreeTierLimits.maxSavedItems
    }
    
    func refresh() {
        items = storage.fetchAll()
    }
    
    func delete(_ item: SavedItem) {
        storage.delete(item)
        refresh()
    }
    
    func toggleFavorite(_ item: SavedItem) {
        item.isFavorited.toggle()
        storage.update()
        refresh()
    }
    
    func importSharedContent() {
        let count = storage.importSharedContent()
        if count > 0 {
            refresh()
        }
    }
    
    func processItem(_ item: SavedItem) async {
        guard let text = item.originalText, !text.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        // 分类
        let category = await aiService.categorize(text, title: item.title)
        item.category = category
        
        // 摘要
        let summary = await aiService.generateSummary(for: text)
        item.summary = summary
        
        // 标签
        let tagNames = await aiService.generateTags(text, title: item.title)
        item.tags = tagNames.map { AITag(name: $0, confidence: 0.8) }
        
        item.updatedAt = Date()
        storage.update()
        refresh()
    }
}
