import SwiftUI

struct PostGridItem: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: post.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.1)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.gray.opacity(0.1)
                    @unknown default:
                        Color.gray.opacity(0.1)
                    }
                }
                .frame(height: 220) // Fixed height for now, can be dynamic for true masonry
                .clipped()
                
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
                // Caption
                Text(post.caption)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
                
                // User & Likes Row
                HStack {
                    // User Avatar
                    if let avatarUrl = post.profile?.avatarUrl, let url = URL(string: avatarUrl) {
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
                    
                    Text(post.profile?.profileName ?? "User")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Likes (Placeholder - No likes table yet)
                    Image(systemName: "heart")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("0")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
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
