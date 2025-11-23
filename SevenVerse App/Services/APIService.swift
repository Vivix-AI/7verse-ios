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
        print("🔍 [APIService] Fetching from table: 7verse_posts")
        
        do {
            let posts: [Post] = try await client
                .from("7verse_posts")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("✅ [APIService] Successfully decoded \(posts.count) posts")
            
            // 打印第一个 post 的详细信息（如果有的话）
            if let firstPost = posts.first {
                print("📋 [APIService] First post preview:")
                print("   - ID: \(firstPost.id)")
                print("   - Caption: \(firstPost.caption.prefix(50))...")
                print("   - Image URL: \(firstPost.imageUrl)")
                print("   - Hashtags: \(firstPost.hashtags)")
                print("   - Premium: \(firstPost.isPremium)")
            }
            
            return posts
        } catch {
            print("❌ [APIService] FATAL ERROR: \(error)")
            print("❌ [APIService] Error type: \(type(of: error))")
            print("❌ [APIService] Error details: \(String(describing: error))")
            
            // 如果是解码错误，打印更多信息
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ [APIService] Missing key '\(key.stringValue)' at: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("❌ [APIService] Type mismatch for type '\(type)' at: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("❌ [APIService] Value not found for type '\(type)' at: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("❌ [APIService] Data corrupted at: \(context.codingPath)")
                @unknown default:
                    print("❌ [APIService] Unknown decoding error")
                }
            }
            
            throw error
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
