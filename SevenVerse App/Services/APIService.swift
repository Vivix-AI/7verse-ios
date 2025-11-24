import Foundation
import Supabase

// MARK: - API Service

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
                        avatar_thumbnail_url,
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
    
    // Fetch posts by profile ID
    func fetchPostsByProfile(profileId: UUID) async throws -> [Post] {
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
                        avatar_thumbnail_url,
                        followers_count,
                        following_count
                    )
                """)
                .eq("profile_id", value: profileId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            return posts
        } catch {
            print("❌ [APIService] Failed to fetch posts for profile: \(error)")
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
    
    // MARK: - Post Interactions
    
    // Toggle Like for a Post
    func toggleLike(postId: UUID, isLiked: Bool) async throws {
        // Workaround: Use raw HTTP request instead of RPC helper
        // This avoids the Sendable conformance issue with mixed-type params
        guard let baseURL = URL(string: Secrets.supabaseURL) else {
            throw APIError.invalidURL
        }
        
        let url = baseURL.appendingPathComponent("rest/v1/rpc/toggle_post_like")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.supabaseServiceRoleKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(Secrets.supabaseServiceRoleKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "post_id": postId.uuidString,
            "is_liked": isLiked
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed(NSError(domain: "APIService", code: -1))
        }
        
        print("✅ [APIService] Successfully toggled like for post: \(postId)")
    }
    
}
