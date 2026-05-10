import SwiftUI

struct DetailView: View {
    let item: SavedItem
    @ObservedObject var viewModel: ContentViewModel
    @State private var showShareSheet = false
    @State private var isProcessing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 来源标签
                HStack {
                    Image(systemName: item.sourceType.iconName)
                        .foregroundColor(.secondary)
                    Text(item.sourceType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.createdAt.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 标题
                Text(item.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // URL
                if let url = item.url, !url.isEmpty {
                    Link(destination: URL(string: url) ?? URL(string: "about:blank")!) {
                        HStack {
                            Image(systemName: "link")
                                .font(.caption)
                            Text(url)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
                
                Divider()
                
                // 分类 + 标签
                HStack {
                    if let category = item.category {
                        Label(category, systemImage: "folder")
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    ForEach(item.tags, id: \.name) { tag in
                        Text(tag.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.toggleFavorite(item) }) {
                        Image(systemName: item.isFavorited ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
                
                Divider()
                
                // AI 摘要
                if let summary = item.summary {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.blue)
                            Text("AI 摘要")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        Text(summary)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                } else {
                    // 还没处理
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("点击下方按钮，AI 将自动生成摘要和分类")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            Task { await process() }
                        }) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                                Text(isProcessing ? "处理中..." : "✨ AI 处理")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing)
                    }
                    .padding()
                }
                
                // 原文
                if let text = item.originalText, !text.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.secondary)
                            Text("原文")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Text(text)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    private func process() async {
        isProcessing = true
        await viewModel.processItem(item)
        isProcessing = false
    }
}
