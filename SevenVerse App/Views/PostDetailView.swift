import SwiftUI

struct PostDetailView: View {
    @ObservedObject var viewModel: FeedViewModel
    @State private var currentPostId: UUID?
    @Environment(\.dismiss) private var dismiss

    init(viewModel: FeedViewModel, initialPostId: UUID? = nil) {
        self.viewModel = viewModel
        _currentPostId = State(initialValue: initialPostId)
    }
    
    var body: some View {
        TabView(selection: $currentPostId) {
            ForEach(viewModel.posts, id: \.id) { post in
                PostDetailItemView(post: post)
                    .tag(post.id as UUID?)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct PostDetailItemView: View {
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Full Width Image
                AsyncImage(url: URL(string: post.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .empty:
                        Color.gray.opacity(0.2)
                            .aspectRatio(3/4, contentMode: .fit)
                    case .failure:
                        ZStack {
                            Color.gray.opacity(0.2)
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        .aspectRatio(3/4, contentMode: .fit)
                    @unknown default:
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Content Section
                VStack(alignment: .leading, spacing: 16) {
                    // Header with date and premium badge
                    HStack {
                        Text(post.displayDate)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        if post.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.caption2)
                                Text("PREMIUM")
                                    .font(.caption2)
                                    .fontWeight(.black)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .cornerRadius(6)
                        }
                        
                        Spacer()
                    }
                    
                    // Caption
                    Text(post.caption)
                        .font(.body)
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Hashtags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(post.hashtags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Profile Info (if available)
                    if let profile = post.profile {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: profile.avatarUrl ?? "")) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                default:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.gray)
                                        )
                                }
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.profileName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                if let bio = profile.bio {
                                    Text(bio)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    
                    // CTA Button (if available)
                    if let ctaUrl = post.ctaUrl, let url = URL(string: ctaUrl) {
                        Link(destination: url) {
                            HStack {
                                Text("Learn More")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(16)
                .background(Color.white)
            }
        }
        .background(Color.white)
    }
}
