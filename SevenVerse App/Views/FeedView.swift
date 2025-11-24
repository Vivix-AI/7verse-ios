import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    @State private var selectedPostId: UUID?
    @State private var showPostDetail = false
    
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
                                ForEach(0..<6, id: \.self) { _ in
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
                                        print("🟢 [FeedView] posts.count: \(viewModel.posts.count)")
                                        print("🟢 [FeedView] groupedPosts.count: \(viewModel.groupedPosts.count)")
                                        
                                        selectedPostId = post.id
                                        
                                        print("🟢 [FeedView] selectedPostId NOW: \(selectedPostId?.uuidString ?? "STILL NIL!")")
                                        
                                        // Add slight delay to ensure state update
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            print("🟢 [FeedView] About to show detail, selectedPostId: \(selectedPostId?.uuidString ?? "NIL!")")
                                            showPostDetail = true
                                        }
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
        .fullScreenCover(isPresented: $showPostDetail) {
            if let postId = selectedPostId {
                PostDetailView(
                    groupedPosts: viewModel.groupedPosts,
                    initialPostId: postId,
                    isPresented: $showPostDetail
                )
                .onAppear {
                    print("✅ [FeedView] fullScreenCover presenting with postId: \(postId)")
                }
            } else {
                ZStack {
                    Color.red.ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        // Top Navigation Bar
                        HStack {
                            Button(action: {
                                showPostDetail = false
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .foregroundColor(.white)
                                .padding()
                            }
                            Spacer()
                        }
                        .background(Color.black.opacity(0.3))
                        
                        Spacer()
                        
                        // Error Content
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text("ERROR: No Post ID")
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Text("selectedPostId is nil")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button("Close") {
                                showPostDetail = false
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white)
                        }
                        
                        Spacer()
                    }
                }
                .onAppear {
                    print("❌ [FeedView] fullScreenCover ERROR: selectedPostId is nil!")
                    print("❌ [FeedView] showPostDetail: \(showPostDetail)")
                }
            }
        }
    }
}
