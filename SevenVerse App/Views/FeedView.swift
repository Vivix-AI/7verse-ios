import SwiftUI

// Wrapper to make UUID Identifiable for fullScreenCover
struct IdentifiableUUID: Identifiable {
    let id: UUID
}

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    @State private var selectedPostId: IdentifiableUUID? // For fullScreenCover item binding

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(uiColor: .systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Universal App Navigation Bar
                    AppNavigationBar(
                        leftContent: .logo,
                        showSearch: true,
                        showNotifications: true,
                        onSearchTap: {
                            print("Search tapped")
                        },
                        onNotificationTap: {
                            print("Notifications tapped")
                        }
                    )

                    // Content
                    if viewModel.isLoading && viewModel.posts.isEmpty {
                        // Skeleton Loading State
                        ScrollView {
                            WaterfallLayout(columns: 2, spacing: 8) {
                                ForEach(0 ..< 6, id: \.self) { _ in
                                    SkeletonPostCard()
                                }
                            }
                            .padding(8)
                        }
                    } else {
                        // Actual Content with Waterfall Layout
                        ScrollView {
                            WaterfallLayout(columns: 2, spacing: 8) {
                                ForEach(viewModel.posts) { post in
                                    Button(action: {
                                        print("🟢 [FeedView] Tapped post ID: \(post.id)")
                                        print("🟢 [FeedView] groupedPosts.count: \(viewModel.groupedPosts.count)")

                                        // Check if groupedPosts is ready
                                        guard !viewModel.groupedPosts.isEmpty else {
                                            print("❌ [FeedView] groupedPosts is empty! Cannot open detail.")
                                            return
                                        }

                                        // Set selectedPostId to trigger fullScreenCover
                                        selectedPostId = IdentifiableUUID(id: post.id)
                                    }) {
                                        PostGridItem(post: post)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(8)

                            // Bottom padding for TabBar (reduced)
                            Color.clear.frame(height: 60)
                        }
                        .refreshable {
                            await viewModel.loadData()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.light)
        .fullScreenCover(item: $selectedPostId) { identifiablePostId in
            // Use item binding - more reliable than isPresented
            if !viewModel.groupedPosts.isEmpty {
                PostDetailView(
                    groupedPosts: viewModel.groupedPosts,
                    initialPostId: identifiablePostId.id,
                    isPresented: Binding(
                        get: { selectedPostId != nil },
                        set: { if !$0 { selectedPostId = nil } }
                    )
                )
                .onAppear {
                    print("✅ [FeedView] PostDetailView appeared with postId: \(identifiablePostId.id)")
                }
            } else {
                // Error state
                ZStack {
                    Color.red.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        Text("ERROR: Data not ready")
                            .font(.title)
                            .foregroundColor(.white)
                        Button("Close") {
                            selectedPostId = nil
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
}
