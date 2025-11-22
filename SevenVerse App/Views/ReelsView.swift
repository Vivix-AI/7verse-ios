import SwiftUI

struct ReelsView: View {
    @ObservedObject var viewModel: FeedViewModel
    @State private var currentPostId: UUID? // UUID type
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentPostId) {
                ForEach(viewModel.posts + viewModel.premiumPosts, id: \.id) { post in
                    ReelItemView(post: post)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .rotationEffect(.degrees(-90))
                        .tag(post.id as UUID?)
                }
            }
            .rotationEffect(.degrees(90))
            .frame(width: geometry.size.height, height: geometry.size.width)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .background(Color.black)
        }
        .ignoresSafeArea()
    }
}

struct ReelItemView: View {
    let post: Post
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Full Screen Background Image
            AsyncImage(url: URL(string: post.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Color.black
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            
            // Gradient Overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(post.displayDate)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    if post.isPremium {
                        Text("PREMIUM")
                            .font(.caption2)
                            .fontWeight(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(4)
                    }
                }
                
                Text(post.caption) // Renamed from oneLine
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(3)
                
                // Hashtags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(post.hashtags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 50) 
        }
    }
}
