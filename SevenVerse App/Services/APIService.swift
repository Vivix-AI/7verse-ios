import Foundation
import Supabase

class APIService {
    static let shared = APIService()
    
    private let client = SupabaseManager.shared.client
    
    enum APIError: Error {
        case invalidURL
        case requestFailed(Error)
        case invalidResponse
        case decodingError(Error)
    }
    
    // Fetch all posts for public feed (Home)
    func fetchAllPosts() async throws -> [Post] {
        let posts: [Post] = try await client
            .from("7verse_posts")
            .select("*, 7verse_post_premium_details(*)")
            .order("created_at", ascending: false)
            .execute()
            .value
        return posts
    }
    
    // Fetch posts for a specific profile (String ID)
    func fetchPosts(forProfileId profileId: String? = nil) async throws -> [Post] {
        var query = client
            .from("7verse_posts")
            .select("*, 7verse_post_premium_details(*)")
        
        if let pid = profileId {
            query = query.eq("profile_id", value: pid)
        }
        
        let posts: [Post] = try await query
            .order("created_at", ascending: false)
            .execute()
            .value
        return posts
    }
    
    // Fetch Profile Details (String ID)
    func fetchProfile(id: String) async throws -> Profile {
        let profile: Profile = try await client
            .from("7verse_profiles")
            .select("*")
            .eq("id", value: id)
            .single()
            .execute()
            .value
        
        return profile
    }
}
