import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    let profileId: String
    let createdAt: Date
    let caption: String
    let hashtags: [String]
    let imageUrl: String
    let ctaUrl: String?
    let category: String
    
    // Supabase joins often return arrays (One-to-Many or generic join).
    // We map the JSON key to this array, then expose a computed property for the single object.
    private let _premiumDetails: [PremiumDetails]?
    
    var premiumDetails: PremiumDetails? {
        return _premiumDetails?.first
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case profileId = "profile_id"
        case createdAt = "created_at"
        case caption
        case hashtags
        case imageUrl = "image_url"
        case ctaUrl = "cta_url"
        case category
        case _premiumDetails = "7verse_post_premium_details"
    }
    
    var isPremium: Bool {
        return category == "premium"
    }
    
    // MARK: - View Helpers
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Copy Helper for Infinite Scroll Loop
    
    // Creates a copy of the post with a new UUID to avoid SwiftUI collision
    func copyWithNewId() -> Post {
        // Since we can't easily modify let properties or init fully via memberwise in extension without exposing internals,
        // we use Codable or just manual init. Manual init is best.
        // But we don't have a memberwise public init available easily for the private prop.
        // Actually, we can just use the decoder or init if we make one.
        // Let's just encode/decode with ID change? No, performance.
        
        // Best way: Define a custom init that takes all properties
        return Post(
            id: UUID(),
            profileId: self.profileId,
            createdAt: self.createdAt,
            caption: self.caption,
            hashtags: self.hashtags,
            imageUrl: self.imageUrl,
            ctaUrl: self.ctaUrl,
            category: self.category,
            _premiumDetails: self._premiumDetails
        )
    }
}

struct PremiumDetails: Codable, Hashable {
    let priceUSD: Double
    let fullContentUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case priceUSD = "price_usd"
        case fullContentUrl = "full_content_url"
    }
    
    var displayPrice: String {
        return String(format: "$%.2f", priceUSD)
    }
}
