import SwiftUI

struct PostGridItem: View {
    let post: Post
    
    // Use thumbnail if available, otherwise fallback to original
    private var displayImageUrl: String {
        post.thumbnailUrl ?? post.imageUrl
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area - Dynamic height based on image aspect ratio
            AsyncImage(url: URL(string: displayImageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay(
                            ProgressView()
                                .tint(.gray)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                                Text("Failed to load")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(3/4, contentMode: .fit)
                }
            }
            .clipped()
            .overlay(alignment: .topTrailing) {
                // Premium Badge
                if post.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            
            // Info Area
            VStack(alignment: .leading, spacing: 8) {
                // Caption - Max 3 lines, auto-shrink to 2 or 1
                Text(post.caption)
                    .font(.system(size: 13))
                    .foregroundColor(.black)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Profile & Views Row
                HStack(alignment: .center, spacing: 0) {
                    // Profile Avatar
                    if let avatarUrl = post.profile?.displayAvatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            default:
                                Color.gray.opacity(0.3)
                            }
                        }
                        .frame(width: 16, height: 16)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // Profile Name
                    Text(post.profile?.profileName ?? "Unknown")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    // Views
                    HStack(spacing: 3) {
                        Image(systemName: "eye")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Text(post.displayViews)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
