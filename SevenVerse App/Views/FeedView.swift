import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    
    // Grid Config
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(uiColor: .systemGray6).ignoresSafeArea() // Light Gray Background
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(viewModel.posts) { post in
                            NavigationLink(destination: PostDetailView(viewModel: viewModel, initialPostId: post.id)) {
                                PostGridItem(post: post)
                            }
                        }
                    }
                    .padding(8) // Padding around the grid
                    
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
        .preferredColorScheme(.light) // Light Mode
    }
}
