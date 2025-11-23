import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    let profileId: UUID
    let createdAt: Date
    let caption: String
    let hashtags: [String]
    let imageUrl: String
    let ctaUrl: String?
    let isPremium: Bool
    let profile: Profile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case profileId = "profile_id"
        case createdAt = "created_at"
        case caption
        case hashtags
        case imageUrl = "image_url"
        case ctaUrl = "cta_url"
        case isPremium = "is_premium"
        case profile = "7verse_profiles"
    }
    
    // Dev-mode aggressive decoding: crash loudly if data is malformed
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        print("🔍 Decoding Post from JSON...")
        
        id = try container.decode(UUID.self, forKey: .id)
        print("  ✅ id: \(id)")
        
        profileId = try container.decode(UUID.self, forKey: .profileId)
        print("  ✅ profileId: \(profileId)")
        
        caption = try container.decode(String.self, forKey: .caption)
        print("  ✅ caption: \(caption.prefix(50))...")
        
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        print("  ✅ imageUrl: \(imageUrl)")
        
        ctaUrl = try container.decodeIfPresent(String.self, forKey: .ctaUrl)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        profile = try container.decodeIfPresent(Profile.self, forKey: .profile)
        
        // Date Decoding - FAIL FAST if format is wrong
        let dateString = try container.decode(String.self, forKey: .createdAt)
        print("  🔍 Decoding date string: '\(dateString)'")
        
        if let date = ISO8601DateFormatter().date(from: dateString) {
            createdAt = date
            print("  ✅ createdAt (ISO8601): \(date)")
        } else {
            // Try SQL timestamp format
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ssX"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: dateString) {
                createdAt = date
                print("  ✅ createdAt (SQL format): \(date)")
            } else {
                print("  ❌ FATAL: Could not parse date '\(dateString)'")
                fatalError("Invalid date format for Post.createdAt: '\(dateString)'")
            }
        }
        
        // Hashtags Decoding - FAIL FAST if format is wrong
        print("  🔍 Decoding hashtags...")
        if let tags = try? container.decode([String].self, forKey: .hashtags) {
            hashtags = tags
            print("  ✅ hashtags (array): \(tags)")
        } else if let tagsString = try? container.decode(String.self, forKey: .hashtags) {
            print("  ⚠️ hashtags is a String, attempting to parse: '\(tagsString)'")
            if let data = tagsString.data(using: .utf8),
               let decodedTags = try? JSONDecoder().decode([String].self, from: data) {
                hashtags = decodedTags
                print("  ✅ hashtags (JSON string parsed): \(decodedTags)")
            } else {
                // Postgres array format {tag1,tag2}
                let cleaned = tagsString.replacingOccurrences(of: "{", with: "")
                                        .replacingOccurrences(of: "}", with: "")
                                        .replacingOccurrences(of: "\"", with: "")
                hashtags = cleaned.components(separatedBy: ",").filter { !$0.isEmpty }
                print("  ✅ hashtags (Postgres array parsed): \(hashtags)")
            }
        } else {
            print("  ❌ FATAL: Could not decode hashtags at all")
            fatalError("Invalid hashtags format for Post")
        }
        
        print("✅ Post decoded successfully: \(id)")
    }
    
    // Standard Init
    init(id: UUID, profileId: UUID, createdAt: Date, caption: String, hashtags: [String], imageUrl: String, ctaUrl: String?, isPremium: Bool, profile: Profile?) {
        self.id = id
        self.profileId = profileId
        self.createdAt = createdAt
        self.caption = caption
        self.hashtags = hashtags
        self.imageUrl = imageUrl
        self.ctaUrl = ctaUrl
        self.isPremium = isPremium
        self.profile = profile
    }
    
    // MARK: - View Helpers
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
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
            ctaUrl: self.ctaUrl,
            isPremium: self.isPremium,
            profile: self.profile
        )
    }
}
