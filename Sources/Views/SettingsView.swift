import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var subscription = SubscriptionService.shared
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var showRestoreAlert = false
    
    var body: some View {
        List {
            // 订阅区域
            Section {
                VStack(spacing: 12) {
                    Image(systemName: subscription.isPro ? "crown.fill" : "crown")
                        .font(.system(size: 36))
                        .foregroundColor(subscription.isPro ? .yellow : .secondary)
                    
                    Text(subscription.isPro ? "Pro 会员" : "知识捕手 Pro")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if subscription.isPro {
                        Text("无限保存 · AI 智能摘要 · 高级搜索")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("免费用户最多保存 \(FreeTierLimits.maxSavedItems) 条")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                
                if !subscription.isPro {
                    ForEach(products) { product in
                        Button(action: {
                            Task { await purchase(product) }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.displayName)
                                        .font(.headline)
                                    Text(product.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(product.displayPrice)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .disabled(isLoading)
                    }
                    
                    Button("恢复购买") {
                        Task {
                            await subscription.restorePurchases()
                            showRestoreAlert = true
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            } header: {
                Text("会员")
            }
            
            // 使用统计
            Section {
                HStack {
                    Text("已保存")
                    Spacer()
                    Text("\(StorageService.shared.itemCount) 条")
                        .foregroundColor(.secondary)
                }
                if !subscription.isPro {
                    HStack {
                        Text("免费额度")
                        Spacer()
                        Text("\(FreeTierLimits.maxSavedItems) 条")
                            .foregroundColor(.secondary)
                    }
                    ProgressView(
                        value: min(Double(StorageService.shared.itemCount), Double(FreeTierLimits.maxSavedItems)),
                        total: Double(FreeTierLimits.maxSavedItems)
                    )
                    .tint(StorageService.shared.itemCount > FreeTierLimits.maxSavedItems * 3/4 ? .orange : .blue)
                }
            } header: {
                Text("使用统计")
            }
            
            // 关于
            Section {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                Link("隐私政策", destination: URL(string: "https://yourdomain.com/privacy")!)
                Link("用户协议", destination: URL(string: "https://yourdomain.com/terms")!)
            } header: {
                Text("关于")
            }
        }
        .navigationTitle("设置")
        .task {
            await subscription.loadProducts()
            products = subscription.products
        }
        .alert("已恢复购买", isPresented: $showRestoreAlert) {
            Button("好的", role: .cancel) {}
        } message: {
            Text(subscription.isPro ? "已恢复 Pro 会员！" : "没有找到可恢复的购买记录。")
        }
    }
    
    private func purchase(_ product: Product) async {
        isLoading = true
        _ = await subscription.purchase(product)
        isLoading = false
    }
}
