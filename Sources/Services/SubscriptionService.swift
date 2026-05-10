import Foundation
import StoreKit

/// 订阅管理服务
@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var isPro: Bool = false
    @Published var isLoading = false
    
    private var updates: Task<Void, Never>?
    
    // StoreKit 产品 ID
    private let yearlyProductID = "aikc_pro_yearly"
    private let monthlyProductID = "aikc_pro_monthly"
    private let lifetimeProductID = "aikc_pro_lifetime"
    
    var products: [Product] = []
    
    init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    func loadProducts() async {
        let productIDs = Set([yearlyProductID, monthlyProductID, lifetimeProductID])
        products = (try? await Product.products(for: productIDs)) ?? []
    }
    
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        let result = try? await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                isPro = true
                return true
            }
            return false
        case .userCancelled:
            return false
        case .pending:
            return false
        default:
            return false
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        try? await AppStore.sync()
        await updateProStatus()
    }
    
    private func updateProStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID.contains("aikc_pro") {
                    isPro = true
                    return
                }
            }
        }
        isPro = false
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await _ in Transaction.updates {
                await self?.updateProStatus()
            }
        }
    }
}
