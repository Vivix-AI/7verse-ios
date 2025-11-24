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
        do {
            let posts: [Post] = try await client
                .from("7verse_posts")
                .select("""
                    *,
                    7verse_profiles:profile_id (
                        id,
                        profile_name,
                        bio,
                        avatar_url,
                        followers_count,
                        following_count
                    )
                """)
                .execute()
                .value
            return posts
        } catch {
            print("❌ [APIService] Failed to fetch posts: \(error)")
            throw error
        }
    }
    
    // Increment post views
    func incrementPostViews(postId: UUID) async throws {
        do {
            // Use RPC to increment views atomically
            _ = try await client.rpc(
                "increment_post_views",
                params: ["post_id": postId.uuidString]
            ).execute()
            
            print("✅ [APIService] Incremented views for post: \(postId)")
        } catch {
            print("❌ [APIService] Failed to increment views: \(error)")
            // Don't throw - views increment is not critical
        }
    }
    
    // Fetch posts for a specific profile (UUID)
    func fetchPosts(forProfileId profileId: String? = nil) async throws -> [Post] {
        do {
            if let pid = profileId {
                let posts: [Post] = try await client
                    .from("7verse_posts")
                    .select()
                    .eq("profile_id", value: pid)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                return posts
            } else {
                let posts: [Post] = try await client
                    .from("7verse_posts")
                    .select()
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                return posts
            }
        } catch {
            print("❌ [APIService] Failed to fetch posts: \(error)")
            throw error
        }
    }
    
    // Fetch Profile Details (String ID -> UUID)
    func fetchProfile(id: String) async throws -> Profile {
        do {
            let profile: Profile = try await client
                .from("7verse_profiles")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            return profile
        } catch {
            print("❌ [APIService] Failed to fetch profile: \(error)")
            throw error
        }
    }
}
