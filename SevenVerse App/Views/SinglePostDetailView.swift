import SwiftUI

// MARK: - Single Post Detail View (No Scrolling)

struct SinglePostDetailView: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var webViewURL: IdentifiableURL?
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            
            ZStack {
                // Background - always black to prevent white flash
                Color.black.ignoresSafeArea()
                
                // Post Content (single post, full screen)
                PostDetailItemView(
                    post: post,
                    isScrolling: .constant(false)
                )
                .frame(width: screenWidth, height: screenHeight)
                
                // Bottom TabBar (same as PostDetailView)
                VStack {
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 16) {
                        // Left: Like & Remix
                        HStack(spacing: 12) {
                            // Like
                            Button(action: {
                                // TODO: Implement like functionality
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "heart")
                                        .font(.system(size: 20, weight: .regular))
                                        .foregroundColor(.white)
                                    
                                    Text("\(post.likesCount)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(minWidth: 30, alignment: .leading)
                                }
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                            }
                            
                            // Remix
                            Button(action: {
                                // TODO: Implement remix functionality
                            }) {
                                Image(systemName: "arrow.2.squarepath")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            }
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        // Right: CTA Button
                        if let ctaUrl = post.ctaUrl, !ctaUrl.isEmpty {
                            Button(action: {
                                // Validate URL before setting
                                if !ctaUrl.isEmpty, let url = URL(string: ctaUrl) {
                                    webViewURL = IdentifiableURL(url: url)
                                } else {
                                    print("❌ [SinglePost CTA] Invalid URL")
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "hand.tap")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Tap to Interact")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                )
                            }
                            .padding(.trailing, 24)
                        }
                    }
                    .padding(.bottom, 12)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                }
            }
            .overlay(
                // Top Navigation Bar (same position as PostDetailView)
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 62)
                    
                    AppNavigationBar(
                        leftContent: .back(action: {
                            dismiss()
                        }),
                        showShare: true,
                        backgroundColor: .clear,
                        iconColor: .white,
                        onShareTap: {
                            showShareSheet = true
                        }
                    )
                    
                    Spacer()
                }
                , alignment: .top
            )
        }
        .ignoresSafeArea()
        .sheet(item: $webViewURL) { identifiableURL in
            WebViewSheet(url: identifiableURL.url)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(post: post)
        }
    }
}

