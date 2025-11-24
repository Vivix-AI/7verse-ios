import SwiftUI

// MARK: - Single Post Detail View (No Scrolling)

struct SinglePostDetailView: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss
    @State private var showWebView = false
    @State private var showShareSheet = false
    @State private var webViewURL: String?
    
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
                                print("🔍 [SinglePost CTA] Button tapped")
                                print("🔍 [SinglePost CTA] Post ID: \(post.id)")
                                print("🔍 [SinglePost CTA] CTA URL: \(ctaUrl)")
                                
                                // Validate URL before setting
                                if !ctaUrl.isEmpty, URL(string: ctaUrl) != nil {
                                    print("✅ [SinglePost CTA] Setting webViewURL: \(ctaUrl)")
                                    webViewURL = ctaUrl
                                    showWebView = true
                                } else {
                                    print("❌ [SinglePost CTA] Invalid CTA URL: \(ctaUrl)")
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
                            .padding(.trailing, 40)
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
        .sheet(isPresented: $showWebView) {
            if let urlString = webViewURL, !urlString.isEmpty {
                print("🌐 [SinglePost WebView] Opening with URL: \(urlString)")
                if let url = URL(string: urlString) {
                    WebViewSheet(url: url)
                } else {
                    print("❌ [SinglePost WebView] Invalid URL format: \(urlString)")
                    // Error state for invalid URL
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Invalid URL")
                            .font(.headline)
                        Text(urlString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Close") {
                            showWebView = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            } else {
                print("❌ [SinglePost WebView] No URL provided - webViewURL: \(String(describing: webViewURL))")
                // Error state for missing URL
                VStack(spacing: 16) {
                    Image(systemName: "link.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No URL Available")
                        .font(.headline)
                    Text("The interaction link is not available for this post.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Close") {
                        showWebView = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(post: post)
        }
    }
}

