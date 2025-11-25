import Foundation

struct Profile: Identifiable, Codable, Hashable {
    let id: UUID
    let profileName: String
    let bio: String?
    let avatarUrl: String?
    let avatarThumbnailUrl: String?
    let followersCount: Int
    let followingCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case profileName = "profile_name"
        case bio
        case avatarUrl = "avatar_url"
        case avatarThumbnailUrl = "avatar_thumbnail_url"
        case followersCount = "followers_count"
        case followingCount = "following_count"
    }

    // Computed property: Use thumbnail if available, otherwise fallback to original
    var displayAvatarUrl: String? {
        avatarThumbnailUrl ?? avatarUrl
    }

    // Mock for previews if needed
    static let mock = Profile(
        id: UUID(),
        profileName: "Sofia",
        bio: "Soft girl in a hard world",
        avatarUrl: "https://storage.googleapis.com/sofia-her-lives-media/sofia/images/20250828-0001.jpg",
        avatarThumbnailUrl: nil,
        followersCount: 120_500,
        followingCount: 240
    )
}
