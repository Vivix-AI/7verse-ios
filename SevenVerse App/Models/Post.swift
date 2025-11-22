import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    let profileId: UUID // Schema says profile_id is uuid, so Swift type should be UUID
    let createdAt: Date
    let caption: String
    let hashtags: [String]
    let imageUrl: String
    let ctaUrl: String?
    let category: String
    let isPremium: Bool // Directly mapped from schema 'is_premium'
    
    enum CodingKeys: String, CodingKey {
        case id
        case profileId = "profile_id"
        case createdAt = "created_at"
        case caption
        case hashtags
        case imageUrl = "image_url"
        case ctaUrl = "cta_url"
        case category
        case isPremium = "is_premium"
    }
    
    // MARK: - View Helpers
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Copy Helper for Infinite Scroll Loop
    
    func copyWithNewId() -> Post {
        return Post(
            id: UUID(),
            profileId: self.profileId,
            createdAt: self.createdAt,
            caption: self.caption,
            hashtags: self.hashtags,
            imageUrl: self.imageUrl,
            ctaUrl: self.ctaUrl,
            category: self.category,
            isPremium: self.isPremium
        )
    }
}
