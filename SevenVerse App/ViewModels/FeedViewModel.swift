import Foundation
import Combine

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var groupedPosts: [[Post]] = [] // Pre-calculated for detail view
    @Published var isLoading = false
    @Published var currentProfile: Profile?
    @Published var errorMessage: String?
    
    // Macro for loop count (0 means no loop, 5 means repeat 5 times)
    private let feedLoopCount = 5
    private var loadTask: Task<Void, Never>?
    
    init() {
        // Removed cache loading - always fetch fresh data
        loadTask = Task {
            await loadData()
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    // MARK: - Data Processing
    
    private func updateGroupedPosts() {
        // Group by profileId
        let groupedDict = Dictionary(grouping: posts, by: { $0.profileId })
        
        // Sort profiles by their most recent post date (descending)
        let sortedGroups = groupedDict.values.sorted { group1, group2 in
            let date1 = group1.first?.createdAt ?? Date.distantPast
            let date2 = group2.first?.createdAt ?? Date.distantPast
            return date1 > date2
        }
        
        // Ensure posts within each profile are also sorted (descending)
        self.groupedPosts = sortedGroups.map { group in
            group.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    // MARK: - Data Loading
    
    @MainActor
    func loadData(forceRefresh: Bool = false) async {
        // Prevent multiple simultaneous loads
        guard !isLoading else {
            print("⚠️ [FeedViewModel] Load already in progress, skipping")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch Public Feed (All Posts)
            let allPosts = try await APIService.shared.fetchAllPosts()
            
            if allPosts.isEmpty {
                print("⚠️ [FeedViewModel] Post array is empty.")
                self.errorMessage = "No posts found. Please check database."
            } else {
                // Loop Logic: Duplicate content to simulate infinite feed
                var expandedPosts = allPosts
                if feedLoopCount > 0 && !allPosts.isEmpty {
                    let originalPosts = allPosts
                    for _ in 0..<feedLoopCount {
                        let duplicates = originalPosts.map { $0.copyWithNewId() }
                        expandedPosts.append(contentsOf: duplicates)
                    }
                }
                
                self.posts = expandedPosts
                // Update grouped data immediately
                updateGroupedPosts()
            }
            
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
            
            #if DEBUG
            print("❌ [FeedViewModel] DEBUG MODE: Would crash in dev mode")
            #endif
        }
        
        isLoading = false
    }
    
    // MARK: - View Increment
    
    func incrementViews(for postId: UUID) async {
        Task {
            try? await APIService.shared.incrementPostViews(postId: postId)
        }
    }
}
