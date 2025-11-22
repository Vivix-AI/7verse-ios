import SwiftUI

struct PostGridItem: View {
    let post: Post
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                // Image Layer
                // Using imageUrl directly, assuming it's a full URL
                AsyncImage(url: URL(string: post.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.gray.opacity(0.3)
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                
                // Premium Badge
                if post.isPremium {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .padding(6)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding(4)
                }
            }
        }
        .aspectRatio(4/5, contentMode: .fit)
        .background(Color.neutral900)
    }
}

extension Color {
    static let neutral900 = Color(red: 0.1, green: 0.1, blue: 0.1)
}
