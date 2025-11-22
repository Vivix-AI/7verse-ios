import Foundation
import Combine

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var currentProfile: Profile? // Keep profile if needed for other logic, or remove
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
            // 1. Fetch Public Feed (All Posts)
            var allPosts = try await APIService.shared.fetchAllPosts()
            
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
            self.errorMessage = "Failed to load feed"
        }
        
        self.isLoading = false
    }
}
