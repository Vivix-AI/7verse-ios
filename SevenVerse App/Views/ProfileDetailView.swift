import SwiftUI

// MARK: - Profile Detail View

struct ProfileDetailView: View {
    let profile: Profile
    @Environment(\.dismiss) private var dismiss
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var selectedPost: Post?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation Bar
                AppNavigationBar(
                    leftContent: .back(action: {
                        dismiss()
                    })
                )

                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        VStack(spacing: 16) {
                            // Avatar
                            AsyncImage(url: URL(string: profile.displayAvatarUrl ?? "")) { phase in
                                switch phase {
                                case let .success(image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                default:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.gray)
                                        )
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())

                            // Name
                            Text(profile.profileName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)

                            // Bio
                            if let bio = profile.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }

                            // Followers & Following
                            HStack(spacing: 40) {
                                VStack(spacing: 4) {
                                    Text("\(profile.followersCount)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Followers")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }

                                VStack(spacing: 4) {
                                    Text("\(profile.followingCount)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Following")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 32)

                        // Posts Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Posts")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)

                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                            } else if posts.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("No posts yet")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                // Grid of posts (tappable)
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 2),
                                    GridItem(.flexible(), spacing: 2),
                                    GridItem(.flexible(), spacing: 2),
                                ], spacing: 2) {
                                    ForEach(posts) { post in
                                        Button(action: {
                                            selectedPost = post
                                        }) {
                                            PostGridItemView(post: post)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedPost) { post in
            SinglePostDetailView(post: post)
        }
        .onAppear {
            loadPosts()
        }
    }

    private func loadPosts() {
        print("🔍 [ProfileDetailView] Loading posts for profile: \(profile.profileName)")
        isLoading = true

        Task {
            do {
                let fetchedPosts = try await APIService.shared.fetchPostsByProfile(profileId: profile.id)
                print("✅ [ProfileDetailView] Loaded \(fetchedPosts.count) posts")
                await MainActor.run {
                    posts = fetchedPosts
                    isLoading = false
                }
            } catch {
                print("❌ [ProfileDetailView] Failed to load posts: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Post Grid Item View (for profile grid)

struct PostGridItemView: View {
    let post: Post

    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: post.thumbnailUrl ?? post.imageUrl)) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .tint(.gray)
                        )
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
