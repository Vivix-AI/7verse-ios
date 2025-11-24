import SwiftUI

// MARK: - Post Detail Item View (Immersive with Blur Background)

struct PostDetailItemView: View {
    let post: Post
    @Binding var isScrolling: Bool
    
    @State private var isLiked = false
    @State private var localLikesCount: Int = 0
    @State private var showWebView = false
    @State private var showProfileDetail = false
    
    private var likedPostsKey: String { "likedPosts" }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Blurred Background Layer
                ZStack {
                    AsyncImage(url: URL(string: post.thumbnailUrl ?? post.imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .blur(radius: 40)
                                .scaleEffect(1.2)
                        case .empty:
                            Color.black
                        case .failure:
                            Color.black
                        @unknown default:
                            Color.black
                        }
                    }
                    
                    // Dark overlay to make background darker
                    Color.black.opacity(0.5)
                }
                .clipped()
                .ignoresSafeArea()
                
                // Foreground Image
                AsyncImage(url: URL(string: post.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    case .empty:
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                            Text("Loading image...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    case .failure:
                        VStack(spacing: 12) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            Text("Failed to load image")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    @unknown default:
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Content Overlay (固定从下至上布局)
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    
                    // Content Area
                    VStack(alignment: .leading, spacing: 12) {
                        // Premium Badge
                        if post.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 11))
                                Text("PREMIUM")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.yellow)
                            .clipShape(Capsule())
                        }
                        
                        // Profile Info (Tappable)
                        if let profile = post.profile {
                            Button(action: {
                                showProfileDetail = true
                            }) {
                                HStack(spacing: 10) {
                                    AsyncImage(url: URL(string: profile.displayAvatarUrl ?? "")) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        default:
                                            Circle()
                                                .fill(Color.white.opacity(0.3))
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white)
                                                )
                                        }
                                    }
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                    
                                    Text(profile.profileName)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Caption
                        Text(post.caption)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Hashtags
                        if !post.hashtags.isEmpty {
                            Text(post.hashtags.map { "#\($0)" }.joined(separator: " "))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.5, green: 0.7, blue: 0.8))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, -6)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 96) // TabBar (80pt) + Page Indicator space (16pt)
                }
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showWebView) {
            if let ctaUrl = post.ctaUrl, let url = URL(string: ctaUrl) {
                WebViewSheet(url: url)
            }
        }
        .fullScreenCover(isPresented: $showProfileDetail) {
            if let profile = post.profile {
                ProfileDetailView(profile: profile)
            }
        }
        .onAppear {
            loadInitialStates()
        }
    }
    
    private func loadInitialStates() {
        let likedPosts = UserDefaults.standard.stringArray(forKey: likedPostsKey) ?? []
        isLiked = likedPosts.contains(post.id.uuidString)
        localLikesCount = post.likesCount
        if isLiked { localLikesCount += 1 }
    }
    
    private func toggleLike() {
        var likedPosts = UserDefaults.standard.stringArray(forKey: likedPostsKey) ?? []
        
        if isLiked {
            likedPosts.removeAll(where: { $0 == post.id.uuidString })
            localLikesCount -= 1
        } else {
            likedPosts.append(post.id.uuidString)
            localLikesCount += 1
        }
        UserDefaults.standard.set(likedPosts, forKey: likedPostsKey)
        isLiked.toggle()
        
        print("Post \(post.id) like status: \(isLiked), count: \(localLikesCount)")
    }
    
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000.0)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000.0)
        } else {
            return "\(count)"
        }
    }
}

