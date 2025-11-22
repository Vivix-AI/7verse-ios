import Foundation

struct Profile: Identifiable, Codable, Hashable {
    let id: String // Changed back to String for 'sofia'
    let username: String
    let bio: String?
    let avatarUrl: String?
    let followersCount: Int
    let followingCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case bio
        case avatarUrl = "avatar_url"
        case followersCount = "followers_count"
        case followingCount = "following_count"
    }
    
    static let sofia = Profile(
        id: "sofia",
        username: "mingy.song@gmail.com",
        bio: "Soft girl in a hard world — splitting her days between workouts, beach walks, office chaos and getting lost in new cities.",
        avatarUrl: "https://storage.googleapis.com/sofia-her-lives-media/sofia/images/20250828-0001.jpg",
        followersCount: 120500,
        followingCount: 240
    )
}
