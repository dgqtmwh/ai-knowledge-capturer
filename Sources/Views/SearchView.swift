import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var searchText = ""
    @State private var searchResults: [SavedItem] = []
    
    var body: some View {
        VStack {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索标题、摘要、内容...", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)
            
            if searchText.isEmpty {
                // 空状态 — 展示热门搜索建议
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "magnifyingglass.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("输入关键词搜索你保存的知识")
                        .foregroundColor(.secondary)
                    
                    Text("💡 试试搜：Swift、AI、设计、产品")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else if searchResults.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.folder")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("没有找到「\(searchText)」相关内容")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(searchResults) { item in
                        NavigationLink(destination: DetailView(item: item, viewModel: viewModel)) {
                            ItemRow(item: item)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("搜索")
        .onChange(of: searchText) { _, newValue in
            guard !newValue.isEmpty else {
                searchResults = []
                return
            }
            // 实时搜索
            searchResults = viewModel.items.filter { item in
                item.title.localizedStandardContains(newValue) ||
                (item.summary ?? "").localizedStandardContains(newValue) ||
                (item.category ?? "").localizedStandardContains(newValue) ||
                item.tags.contains(where: { $0.name.localizedStandardContains(newValue) })
            }
        }
    }
}
