import SwiftUI

struct ContentListView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 分类筛选横条
            categoryScroll
            
            if viewModel.filteredItems.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.filteredItems) { item in
                        NavigationLink(destination: DetailView(item: item, viewModel: viewModel)) {
                            ItemRow(item: item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.delete(item)
                                }
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.toggleFavorite(item)
                            } label: {
                                Label(
                                    item.isFavorited ? "取消收藏" : "收藏",
                                    systemImage: item.isFavorited ? "star.slash" : "star"
                                )
                            }
                            .tint(.yellow)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("知识捕手")
        .onAppear {
            viewModel.importSharedContent()
        }
    }
    
    private var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { cat in
                    Button(action: {
                        viewModel.selectedCategory = cat == "全部" ? nil : cat
                    }) {
                        Text(cat)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                (viewModel.selectedCategory == cat) ||
                                (cat == "全部" && viewModel.selectedCategory == nil)
                                ? Color.blue : Color(.systemGray6)
                            )
                            .foregroundColor(
                                (viewModel.selectedCategory == cat) ||
                                (cat == "全部" && viewModel.selectedCategory == nil)
                                ? .white : .primary
                            )
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("还没有收藏任何内容")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("在其他 App 中点「分享」→ 选择「知识捕手」\n就可以保存到这里")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
}

struct ItemRow: View {
    let item: SavedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: item.sourceType.iconName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(item.sourceType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if item.isFavorited {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Text(item.title)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(2)
            
            if let summary = item.summary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if let category = item.category {
                    Text(category)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                if !item.tags.isEmpty {
                    ForEach(item.tags.prefix(2), id: \.name) { tag in
                        Text(tag.name)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .foregroundColor(.secondary)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Text(item.createdAt.formatted(.relative(presentation: .numeric)))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
