import SwiftUI

/// Subscription management and upgrade view
@available(iOS 15.0, *)
public struct SubscriptionView: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var status: SubscriptionManager.SubscriptionStatus
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    public init() {
        let manager = SubscriptionManager()
        self._status = State(initialValue: manager.getStatus())
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Status
                CurrentStatusCard(status: status)
                
                // Subscription Tiers
                if subscriptionManager.canUpgrade() {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upgrade Your Plan")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(subscriptionManager.getUpgradeOptions(), id: \.self) { tier in
                            SubscriptionTierCard(
                                tier: tier,
                                isPurchasing: isPurchasing,
                                onPurchase: {
                                    purchaseSubscription(tier: tier)
                                }
                            )
                        }
                    }
                }
                
                // Feature Comparison
                FeatureComparisonView(subscriptionManager: subscriptionManager)
                
                // Restore Purchases Button
                Button(action: restorePurchases) {
                    Text("Restore Purchases")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.blue)
                }
                .disabled(isPurchasing)
            }
            .padding()
        }
        .navigationTitle("Subscription")
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func purchaseSubscription(tier: SubscriptionManager.SubscriptionTier) {
        isPurchasing = true
        
        subscriptionManager.purchaseSubscription(tier: tier) { result in
            isPurchasing = false
            
            switch result {
            case .success(let newStatus):
                status = newStatus
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func restorePurchases() {
        isPurchasing = true
        
        subscriptionManager.restorePurchases { result in
            isPurchasing = false
            
            switch result {
            case .success(let restoredStatus):
                status = restoredStatus
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

@available(iOS 15.0, *)
struct CurrentStatusCard: View {
    let status: SubscriptionManager.SubscriptionStatus
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: iconForTier(status.tier))
                    .font(.title)
                    .foregroundColor(colorForTier(status.tier))
                
                VStack(alignment: .leading) {
                    Text("Current Plan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(status.tier.displayName)
                        .font(.title2)
                        .bold()
                    if status.isActive, let expiration = status.expirationDate {
                        Text("Renews \(expiration, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if status.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func iconForTier(_ tier: SubscriptionManager.SubscriptionTier) -> String {
        switch tier {
        case .free:
            return "person"
        case .basic:
            return "star"
        case .premium:
            return "crown.fill"
        }
    }
    
    private func colorForTier(_ tier: SubscriptionManager.SubscriptionTier) -> Color {
        switch tier {
        case .free:
            return .gray
        case .basic:
            return .blue
        case .premium:
            return .purple
        }
    }
}

@available(iOS 15.0, *)
struct SubscriptionTierCard: View {
    let tier: SubscriptionManager.SubscriptionTier
    let isPurchasing: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(tier.displayName)
                        .font(.title3)
                        .bold()
                    Text(tier.price)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: onPurchase) {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Subscribe")
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(isPurchasing)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(tier.features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(feature)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

@available(iOS 15.0, *)
struct FeatureComparisonView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feature Comparison")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Feature")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Free")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 50)
                    
                    Text("Basic")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 50)
                    
                    Text("Premium")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 60)
                }
                .padding()
                .background(Color(.systemGray5))
                
                // Features
                ForEach(subscriptionManager.getFeatureComparison(), id: \.feature) { item in
                    HStack {
                        Text(item.feature)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CheckmarkView(isChecked: item.free)
                            .frame(width: 50)
                        
                        CheckmarkView(isChecked: item.basic)
                            .frame(width: 50)
                        
                        CheckmarkView(isChecked: item.premium)
                            .frame(width: 60)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    if item.feature != subscriptionManager.getFeatureComparison().last?.feature {
                        Divider()
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
    }
}

@available(iOS 15.0, *)
struct CheckmarkView: View {
    let isChecked: Bool
    
    var body: some View {
        if isChecked {
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.caption)
        } else {
            Image(systemName: "minus")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}
