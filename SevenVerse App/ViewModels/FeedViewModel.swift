import Foundation
import Combine

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var currentProfile: Profile?
    @Published var errorMessage: String?
    
    // Macro for loop count (0 means no loop, 5 means repeat 5 times)
    private let feedLoopCount = 5
    private var loadTask: Task<Void, Never>?
    
    init() {
        loadTask = Task {
            await loadData()
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    @MainActor
    func loadData() async {
        // Prevent multiple simultaneous loads
        guard !isLoading else {
            print("⚠️ [FeedViewModel] Load already in progress, skipping")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔄 [FeedViewModel] Loading feed data...")
            
            // 1. Fetch Public Feed (All Posts)
            let allPosts = try await APIService.shared.fetchAllPosts()
            print("✅ [FeedViewModel] Successfully fetched \(allPosts.count) posts from Supabase")
            
            if allPosts.isEmpty {
                print("⚠️ [FeedViewModel] Post array is empty.")
                print("💡 [FeedViewModel] Possible reasons:")
                print("   - Database table '7verse_posts' has no data")
                print("   - Check Supabase dashboard to verify data exists")
                self.errorMessage = "No posts found. Please check database."
            }
            
            // 2. Loop Logic: Duplicate content to simulate infinite feed
            var expandedPosts = allPosts
            if feedLoopCount > 0 && !allPosts.isEmpty {
                let originalPosts = allPosts
                for _ in 0..<feedLoopCount {
                    let duplicates = originalPosts.map { $0.copyWithNewId() }
                    expandedPosts.append(contentsOf: duplicates)
                }
                print("✅ [FeedViewModel] Looped posts \(feedLoopCount) times, total: \(expandedPosts.count)")
            }
            
            self.posts = expandedPosts
            
        } catch is CancellationError {
            print("⚠️ [FeedViewModel] Load was cancelled")
        } catch {
            let nsError = error as NSError
            
            // Handle cancelled requests gracefully (not a real error)
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                print("⚠️ [FeedViewModel] Request was cancelled (normal during view updates)")
                return
            }
            
            print("❌ [FeedViewModel] Failed to load feed - \(error)")
            self.errorMessage = "Failed to load feed: \(error.localizedDescription)"
            
            // Don't crash in production, just show error
            #if DEBUG
            print("❌ [FeedViewModel] DEBUG MODE: Would crash in dev mode")
            // fatalError("Cannot load feed data: \(error)")
            #endif
        }
        
        isLoading = false
    }
}
