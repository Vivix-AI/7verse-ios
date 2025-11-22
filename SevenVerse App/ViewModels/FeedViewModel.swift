import Foundation
import Combine

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var currentProfile: Profile?
    @Published var errorMessage: String?
    
    // Macro for loop count (0 means no loop, 5 means repeat 5 times)
    private let feedLoopCount = 5
    
    init() {
        Task {
            await loadData()
        }
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔄 Loading feed data...")
            // 1. Fetch Public Feed (All Posts)
            var allPosts = try await APIService.shared.fetchAllPosts()
            print("✅ Successfully fetched \(allPosts.count) posts from Supabase")
            
            if allPosts.isEmpty {
                print("⚠️ Warning: Post array is empty. Check RLS policies or DB content.")
            }
            
            // 2. Loop Logic: Duplicate content to simulate infinite feed
            if feedLoopCount > 0 && !allPosts.isEmpty {
                let originalPosts = allPosts
                for _ in 0..<feedLoopCount {
                    // Create copies with new IDs to satisfy Identifiable
                    let duplicates = originalPosts.map { $0.copyWithNewId() }
                    allPosts.append(contentsOf: duplicates)
                }
            }
            
            self.posts = allPosts
            
        } catch {
            print("Failed to load feed: \(error)")
            self.errorMessage = "Failed to load feed: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
}
