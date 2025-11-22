import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    
    // Masonry / Waterfall Grid Layout
    // Standard LazyVGrid with 2 columns is sufficient for now.
    // If heights vary significantly, we might need a custom MasonryVStack.
    // For "Xiaohongshu style", typically aspect ratios vary (3:4, 1:1, 16:9).
    // LazyVGrid aligns rows, so tall items will leave gaps in the shorter neighbor.
    // To do TRUE masonry, we need two VStacks. Let's implement the dual-VStack approach for better aesthetics.
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    HStack(alignment: .top, spacing: 8) {
                        // Column 1 (Left)
                        LazyVStack(spacing: 8) {
                            ForEach(splitPosts.left) { post in
                                FeedCardView(post: post)
                            }
                        }
                        
                        // Column 2 (Right)
                        LazyVStack(spacing: 8) {
                            ForEach(splitPosts.right) { post in
                                FeedCardView(post: post)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    // Bottom padding for TabBar
                    Color.clear.frame(height: 80)
                }
                .refreshable {
                    await viewModel.loadData()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .top)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.light)
    }
    
    // Helper to split posts into two columns for Masonry effect
    private var splitPosts: (left: [Post], right: [Post]) {
        var left: [Post] = []
        var right: [Post] = []
        
        for (index, post) in viewModel.posts.enumerated() {
            if index % 2 == 0 {
                left.append(post)
            } else {
                right.append(post)
            }
        }
        return (left, right)
    }
}

// New "Xiaohongshu Style" Card
struct FeedCardView: View {
    let post: Post
    
    var body: some View {
        NavigationLink(destination: Text("Detail View for \(post.id)")) {
            VStack(alignment: .leading, spacing: 8) {
                // Image
                AsyncImage(url: URL(string: post.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit) // Maintain aspect ratio (Masonry key)
                    default:
                        Color.gray.opacity(0.1)
                            .aspectRatio(3/4, contentMode: .fit) // Placeholder ratio
                    }
                }
                .cornerRadius(8)
                .clipped()
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.caption)
                        .font(.system(size: 14))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)
                    
                    HStack {
                        // User Avatar (Tiny)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                        
                        Text("User")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Image(systemName: "heart")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("100")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 8)
            }
            .background(Color.white)
            // Optional: Drop shadow or border for card effect
        }
        .buttonStyle(PlainButtonStyle()) // Remove standard link styling
    }
}
