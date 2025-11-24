import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    let profileId: UUID
    let createdAt: Date
    let caption: String
    let hashtags: [String]
    let imageUrl: String
    let thumbnailUrl: String?
    let ctaUrl: String?
    let isPremium: Bool
    let views: Int
    let profile: Profile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case profileId = "profile_id"
        case createdAt = "created_at"
        case caption
        case hashtags
        case imageUrl = "image_url"
        case thumbnailUrl = "thumbnail_url"
        case ctaUrl = "cta_url"
        case isPremium = "is_premium"
        case views
        case profile = "7verse_profiles"
    }
    
    // Dev-mode aggressive decoding: crash loudly if data is malformed
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        profileId = try container.decode(UUID.self, forKey: .profileId)
        caption = try container.decode(String.self, forKey: .caption)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        ctaUrl = try container.decodeIfPresent(String.self, forKey: .ctaUrl)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        views = (try? container.decode(Int.self, forKey: .views)) ?? 0
        profile = try container.decodeIfPresent(Profile.self, forKey: .profile)
        
        // Date Decoding - FAIL FAST if format is wrong
        let dateString = try container.decode(String.self, forKey: .createdAt)
        
        if let date = ISO8601DateFormatter().date(from: dateString) {
            createdAt = date
        } else {
            // Try SQL timestamp format
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ssX"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: dateString) {
                createdAt = date
            } else {
                print("❌ [Post] FATAL: Could not parse date '\(dateString)'")
                fatalError("Invalid date format for Post.createdAt: '\(dateString)'")
            }
        }
        
        // Hashtags Decoding - FAIL FAST if format is wrong
        if let tags = try? container.decode([String].self, forKey: .hashtags) {
            hashtags = tags
        } else if let tagsString = try? container.decode(String.self, forKey: .hashtags) {
            if let data = tagsString.data(using: .utf8),
               let decodedTags = try? JSONDecoder().decode([String].self, from: data) {
                hashtags = decodedTags
            } else {
                // Postgres array format {tag1,tag2}
                let cleaned = tagsString.replacingOccurrences(of: "{", with: "")
                                        .replacingOccurrences(of: "}", with: "")
                                        .replacingOccurrences(of: "\"", with: "")
                hashtags = cleaned.components(separatedBy: ",").filter { !$0.isEmpty }
            }
        } else {
            print("❌ [Post] FATAL: Could not decode hashtags")
            fatalError("Invalid hashtags format for Post")
        }
    }
    
    // Standard Init
    init(id: UUID, profileId: UUID, createdAt: Date, caption: String, hashtags: [String], imageUrl: String, thumbnailUrl: String?, ctaUrl: String?, isPremium: Bool, views: Int, profile: Profile?) {
        self.id = id
        self.profileId = profileId
        self.createdAt = createdAt
        self.caption = caption
        self.hashtags = hashtags
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.ctaUrl = ctaUrl
        self.isPremium = isPremium
        self.views = views
        self.profile = profile
    }
    
    // MARK: - View Helpers
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
    
    var displayViews: String {
        if views >= 1_000_000 {
            return String(format: "%.1fM", Double(views) / 1_000_000.0)
        } else if views >= 1_000 {
            return String(format: "%.1fK", Double(views) / 1_000.0)
        } else {
            return "\(views)"
        }
    }
    
    // MARK: - Copy Helper
    
    func copyWithNewId() -> Post {
        return Post(
            id: UUID(),
            profileId: self.profileId,
            createdAt: self.createdAt,
            caption: self.caption,
            hashtags: self.hashtags,
            imageUrl: self.imageUrl,
            thumbnailUrl: self.thumbnailUrl,
            ctaUrl: self.ctaUrl,
            isPremium: self.isPremium,
            views: self.views,
            profile: self.profile
        )
    }
}
