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
        // Removed join with premium_details since the table doesn't exist yet
        let posts: [Post] = try await client
            .from("7verse_posts")
            .select("*") // Select all columns from 7verse_posts only
            .order("created_at", ascending: false)
            .execute()
            .value
        return posts
    }
    
    // Fetch posts for a specific profile (UUID)
    func fetchPosts(forProfileId profileId: String? = nil) async throws -> [Post] {
        var query = client
            .from("7verse_posts")
            .select("*")
        
        if let pid = profileId {
            query = query.eq("profile_id", value: pid)
        }
        
        let posts: [Post] = try await query
            .order("created_at", ascending: false)
            .execute()
            .value
        return posts
    }
    
    // Fetch Profile Details (String ID -> UUID)
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
