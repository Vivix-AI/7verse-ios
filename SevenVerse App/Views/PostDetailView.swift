import SwiftUI
import WebKit
import UIKit

// MARK: - ViewOffsetKey for tracking scroll position
struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct PostDetailView: View {
    let groupedPosts: [[Post]]
    let initialPostId: UUID
    @Binding var isPresented: Bool
    
    // Computed indices (Fast & Safe)
    private var initialIndices: (profile: Int, post: Int) {
        for (pIndex, group) in groupedPosts.enumerated() {
            if let iIndex = group.firstIndex(where: { $0.id == initialPostId }) {
                return (pIndex, iIndex)
            }
        }
        
        return (0, 0)
    }
    
    var body: some View {
        if groupedPosts.isEmpty {
            // Empty state - data not ready yet
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    Text("Loading posts...")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Text("groupedPosts is empty")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Button("Close") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
            }
        } else {
            // Validate that initial indices are valid
            let indices = initialIndices
            
            if indices.profile < groupedPosts.count && 
               indices.post < groupedPosts[indices.profile].count {
                // Main content - indices are valid
                PostDetailCarouselView(
                    groupedPosts: groupedPosts,
                    initialProfileIndex: indices.profile,
                    initialPostIndex: indices.post,
                    onDismiss: {
                        isPresented = false
                    }
                )
        .ignoresSafeArea()
            } else {
                // Error state - invalid indices
                ZStack {
                    Color.red.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("ERROR: Invalid Post")
                            .font(.title)
                        .foregroundColor(.white)
                        
                        Text("Could not find post with ID: \(initialPostId)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Profile: \(indices.profile), Post: \(indices.post)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Button("Close") {
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Post Detail Carousel View

struct PostDetailCarouselView: View {
    let groupedPosts: [[Post]]
    let initialProfileIndex: Int
    let initialPostIndex: Int
    let onDismiss: () -> Void
    
    @State private var currentProfileIndex: Int  // Real index (0 to groupedPosts.count - 1)
    @State private var currentPostIndices: [Int] // Array of current post index for each profile
    @State private var isScrolling = false
    @State private var scrollTimer: Timer?
    @State private var showGreetingsVideo = false
    @State private var greetingsVideoUrl: URL?
    @State private var showShareSheet = false
    @State private var showWebView = false
    @State private var webViewURL: String?
    @State private var scrollOffset: CGFloat = 0
    @State private var isInitialScrollComplete = false
    @State private var loadedProfilesCount = 30 // Start with 30 profiles, will load more as needed
    
    // For infinite downward scrolling
    // We'll create profiles starting from initialProfileIndex
    private var displayProfiles: [(realIndex: Int, virtualIndex: Int)] {
        var profiles: [(Int, Int)] = []
        let totalProfiles = groupedPosts.count
        
        // Start from initialProfileIndex, then continue infinitely
        for i in 0..<loadedProfilesCount {
            let realIndex = (initialProfileIndex + i) % totalProfiles
            profiles.append((realIndex, i))
        }
        
        return profiles
    }
    
    init(groupedPosts: [[Post]], initialProfileIndex: Int, initialPostIndex: Int, onDismiss: @escaping () -> Void) {
        self.groupedPosts = groupedPosts
        self.initialProfileIndex = initialProfileIndex
        self.initialPostIndex = initialPostIndex
        self.onDismiss = onDismiss
        
        // Initialize with real index
        _currentProfileIndex = State(initialValue: initialProfileIndex)
        
        // Initialize post indices array (one for each profile)
        var indices = Array(repeating: 0, count: groupedPosts.count)
        if indices.indices.contains(initialProfileIndex) {
            indices[initialProfileIndex] = initialPostIndex
        }
        _currentPostIndices = State(initialValue: indices)
    }
    
    // Get posts for a profile index
    private func posts(for profileIndex: Int) -> [Post] {
        guard groupedPosts.indices.contains(profileIndex) else { return [] }
        return groupedPosts[profileIndex]
    }
    
    private var currentPost: Post? {
        guard groupedPosts.indices.contains(currentProfileIndex) else {
            return nil
        }
        let posts = groupedPosts[currentProfileIndex]
        let postIndex = currentPostIndices[currentProfileIndex]
        guard posts.indices.contains(postIndex) else {
            return nil
        }
        return posts[postIndex]
    }
    
    private var currentProfilePosts: [Post] {
        return posts(for: currentProfileIndex)
    }
    
    // Preload adjacent posts for smoother scrolling
    private func preloadAdjacentPosts(profileIndex: Int, postIndex: Int) {
        guard groupedPosts.indices.contains(profileIndex) else { return }
        let group = groupedPosts[profileIndex]
        
        // Preload current post
        if group.indices.contains(postIndex) {
            preloadImage(url: group[postIndex].imageUrl)
            preloadImage(url: group[postIndex].thumbnailUrl)
        }
        
        // Preload next post in same profile
        if postIndex + 1 < group.count {
            preloadImage(url: group[postIndex + 1].imageUrl)
            preloadImage(url: group[postIndex + 1].thumbnailUrl)
        }
        
        // Preload previous post in same profile
        if postIndex > 0 {
            preloadImage(url: group[postIndex - 1].imageUrl)
            preloadImage(url: group[postIndex - 1].thumbnailUrl)
        }
        
        // Preload next profile's first post (if exists)
        let nextProfileIndex = profileIndex + 1
        if nextProfileIndex < groupedPosts.count, let firstPost = groupedPosts[nextProfileIndex].first {
            preloadImage(url: firstPost.imageUrl)
            preloadImage(url: firstPost.thumbnailUrl)
        }
        
        // Preload previous profile's first post (if exists)
        let prevProfileIndex = profileIndex - 1
        if prevProfileIndex >= 0, let firstPost = groupedPosts[prevProfileIndex].first {
            preloadImage(url: firstPost.imageUrl)
            preloadImage(url: firstPost.thumbnailUrl)
        }
    }
    
    // Helper to preload image into URLCache
    private func preloadImage(url: String?) {
        guard let urlString = url,
              let imageURL = URL(string: urlString) else { return }
        
        // Check if already cached
        let request = URLRequest(url: imageURL)
        if URLCache.shared.cachedResponse(for: request) != nil {
            return // Already cached
        }
        
        // Preload in background
        Task.detached(priority: .utility) {
            do {
                let (data, response) = try await URLSession.shared.data(from: imageURL)
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            } catch {
                // Silent fail - preloading is not critical
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            mainContent(geometry: geometry)
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func mainContent(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        // Calculate canvas dimensions (full screen for each profile)
        // Canvas should fill the entire screen height
        let canvasHeight = screenHeight
        let canvasWidth = screenWidth
        
        ZStack {
                // Canvas Area (ScrollView with posts) - full screen
                Color.black.ignoresSafeArea()
                
                // Loading overlay during initial scroll
                if !isInitialScrollComplete {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                    .zIndex(999)
                }
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                // Infinite downward scrolling starting from clicked post
                                ForEach(displayProfiles, id: \.virtualIndex) { profile in
                                    let profileIndex = profile.realIndex
                                    let virtualIndex = profile.virtualIndex
                                    let postsForThisProfile = groupedPosts[profileIndex]
                                    
                                    // Each profile: TabView + TabBar
                                    ZStack(alignment: .bottom) {
                                        // Horizontal TabView for posts within THIS profile only
                                        TabView(selection: Binding<Int>(
                                                get: { 
                                                    guard currentPostIndices.indices.contains(profileIndex) else {
                                                        print("⚠️ [TabView] GET - profileIndex \(profileIndex) out of bounds")
                                                        return 0
                                                    }
                                                    return currentPostIndices[profileIndex]
                                                },
                                                set: { newValue in
                                                    guard currentPostIndices.indices.contains(profileIndex),
                                                          newValue < postsForThisProfile.count else {
                                                        print("⚠️ [TabView] SET failed - profileIndex: \(profileIndex), newValue: \(newValue)")
                                                        return
                                                    }
                                                    print("✏️ [TabView] SET - Profile \(profileIndex), \(currentPostIndices[profileIndex]) → \(newValue)")
                                                    currentPostIndices[profileIndex] = newValue
                                                }
                                            )) {
                                                // Only loop through THIS profile's posts (not global)
                                                ForEach(Array(postsForThisProfile.indices), id: \.self) { postIndex in
                                                    PostDetailItemView(
                                                        post: postsForThisProfile[postIndex],
                                                        isScrolling: $isScrolling
                                                    )
                                                    .tag(postIndex)
                                                    .onAppear {
                                                        // Preload adjacent posts
                                                        preloadAdjacentPosts(profileIndex: profileIndex, postIndex: postIndex)
                                                    }
                                                }
                                            }
                                            .tabViewStyle(.page(indexDisplayMode: .never))
                                            .onAppear {
                                                // Ensure the correct post is selected when this TabView appears
                                                // Only for the first profile (virtualIndex == 0)
                                                if virtualIndex == 0 && currentPostIndices[profileIndex] != initialPostIndex {
                                                    print("🔧 [TabView] Fixing initial selection for profile \(profileIndex): \(currentPostIndices[profileIndex]) → \(initialPostIndex)")
                                                    DispatchQueue.main.async {
                                                        currentPostIndices[profileIndex] = initialPostIndex
                                                    }
                                                }
                                            }
                                        
                                        // Bottom TabBar for THIS profile
                                        // Show TabBar for all profiles (not just current)
                                        if !postsForThisProfile.isEmpty {
                                            // Safely get current post index, default to 0 if not set
                                            let currentPostIndex = currentPostIndices.indices.contains(profileIndex) 
                                                ? min(currentPostIndices[profileIndex], postsForThisProfile.count - 1)
                                                : 0
                                            let currentProfilePost = postsForThisProfile[currentPostIndex]
                                            
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
                                                        
                                                        Text("\(currentProfilePost.likesCount)")
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
                                            if let ctaUrl = currentProfilePost.ctaUrl, !ctaUrl.isEmpty {
                                                Button(action: {
                                                    // Safely get current post at click time (not from closure)
                                                    print("🔍 [CTA] Button tapped - profileIndex: \(profileIndex)")
                                                    print("🔍 [CTA] currentPostIndices[\(profileIndex)]: \(currentPostIndices.indices.contains(profileIndex) ? currentPostIndices[profileIndex] : -1)")
                                                    print("🔍 [CTA] ctaUrl from view: \(ctaUrl)")
                                                    
                                                    // Get fresh post data at click time
                                                    guard currentPostIndices.indices.contains(profileIndex) else {
                                                        print("❌ [CTA] Invalid profileIndex: \(profileIndex)")
                                                        return
                                                    }
                                                    
                                                    let posts = postsForThisProfile
                                                    let postIdx = currentPostIndices[profileIndex]
                                                    
                                                    guard posts.indices.contains(postIdx) else {
                                                        print("❌ [CTA] Invalid postIndex: \(postIdx)")
                                                        return
                                                    }
                                                    
                                                    let freshPost = posts[postIdx]
                                                    
                                                    if let freshCtaUrl = freshPost.ctaUrl, !freshCtaUrl.isEmpty {
                                                        print("✅ [CTA] Setting webViewURL: \(freshCtaUrl)")
                                                        webViewURL = freshCtaUrl
                                                        showWebView = true
                                                    } else {
                                                        print("❌ [CTA] No valid CTA URL found in fresh post")
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
                                    .frame(width: canvasWidth, height: canvasHeight)
                                    .background(
                                        GeometryReader { itemGeometry in
                                            Color.clear.preference(
                                                key: ViewOffsetKey.self,
                                                value: itemGeometry.frame(in: .global).minY
                                            )
                                        }
                                    )
                                    .onPreferenceChange(ViewOffsetKey.self) { minY in
                                        let isVisible = minY >= -canvasHeight/2 && minY <= canvasHeight/2
                                            if isVisible {
                                                // Only update when this profile is actually visible
                                                DispatchQueue.main.async {
                                                    print("👁️ [Visibility] Profile visible - virtualIndex: \(virtualIndex), profileIndex: \(profileIndex)")
                                                    currentProfileIndex = profileIndex
                                                    
                                                    // Load more profiles when approaching the end
                                                    if virtualIndex >= loadedProfilesCount - 5 {
                                                        print("📥 [Loading] Loading more profiles - current: \(loadedProfilesCount)")
                                                        loadedProfilesCount += 10
                                                    }
                                                    
                                                    // Check if there's a greetings video for this post
                                                    guard currentPostIndices.indices.contains(profileIndex) else {
                                                        return
                                                    }
                                                    
                                                    let posts = self.posts(for: profileIndex)
                                                    let postIndex = currentPostIndices[profileIndex]
                                                    
                                                    guard posts.indices.contains(postIndex) else {
                                                        return
                                                    }
                                                    
                                                    let currentPost = posts[postIndex]
                                                    
                                                    if let video = currentPost.randomGreetingVideo() {
                                                        greetingsVideoUrl = URL(string: video.url)
                                                        
                                                        // Delay video playback slightly to ensure smooth transition
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                            showGreetingsVideo = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    .id(virtualIndex)
                                }
                            }
                        }
                        .scrollTargetBehavior(.paging) // iOS 17+ paging behavior
                        .scrollDisabled(false) // Enable scrolling
                        .onAppear {
                            // Start from virtualIndex 0 (which is the clicked profile)
                            print("🎯 [PostDetailView] onAppear - Starting at virtualIndex: 0")
                            print("🎯 [PostDetailView] initialProfileIndex: \(initialProfileIndex), initialPostIndex: \(initialPostIndex)")
                            print("🎯 [PostDetailView] currentPostIndices: \(currentPostIndices)")
                            
                            // Verify the post index is set correctly
                            if currentPostIndices.indices.contains(initialProfileIndex) {
                                print("🎯 [PostDetailView] currentPostIndices[\(initialProfileIndex)] = \(currentPostIndices[initialProfileIndex])")
                            }
                            
                            // Delay slightly to ensure view is ready and TabView selection is set
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                print("🎯 [PostDetailView] Scrolling to virtualIndex: 0")
                                proxy.scrollTo(0, anchor: .top)
                                
                                // Hide loading overlay after scroll completes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isInitialScrollComplete = true
                                }
                            }
                    }
                }
            }
            .overlay(
                // Top Navigation Bar (overlay on top, ~62pt from top to match home)
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 62)
                    
                    AppNavigationBar(
                        leftContent: .back(action: onDismiss),
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
            .overlay(
                // Page Indicator (豆豆) - Global overlay, above TabBar
                Group {
                    if currentPost != nil,
                       let currentProfilePosts = groupedPosts[safe: currentProfileIndex],
                       currentProfilePosts.count > 1 {
                        VStack {
                            Spacer()
                            
                            HStack(spacing: 6) {
                                ForEach(0..<currentProfilePosts.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentPostIndices[currentProfileIndex] ? Color.white : Color.white.opacity(0.4))
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .padding(.bottom, 200) // Test: 200pt from bottom
                        }
                    }
                }
                .allowsHitTesting(false) // Don't block interactions
                , alignment: .center
            )
            .overlay(
                // Greetings Video Overlay (Full Screen, on top of everything)
                Group {
                    if showGreetingsVideo, let videoUrl = greetingsVideoUrl {
                        GreetingsVideoPlayer(
                            videoURL: videoUrl,
                            onDismiss: {
                                showGreetingsVideo = false
                                greetingsVideoUrl = nil
                            }
                        )
                        .transition(.opacity)
                    }
                }
            )
            .sheet(isPresented: $showShareSheet) {
                if let post = currentPost {
                    ShareSheet(post: post)
                }
            }
            .sheet(isPresented: $showWebView) {
                Group {
                    if let urlString = webViewURL, !urlString.isEmpty {
                        if let url = URL(string: urlString) {
                            WebViewSheet(url: url)
                                .onAppear {
                                    print("🌐 [WebView Sheet] Opening with URL: \(urlString)")
                                }
                        } else {
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
                            .onAppear {
                                print("❌ [WebView Sheet] Invalid URL format: \(urlString)")
                            }
                        }
                    } else {
                        // Error state for missing URL
                        VStack(spacing: 16) {
                            Image(systemName: "xmark.circle")
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
            }
            .onDisappear {
                // Clean up timer
                scrollTimer?.invalidate()
                scrollTimer = nil
            }
        }
    }

// MARK: - Post Detail Navigation Bar

struct PostDetailNavigationBar: View {
    let post: Post?
    let onBackTapped: () -> Void
    @State private var showShareSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Back Button
            Button(action: onBackTapped) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Share Button (arrow icon)
            Button(action: {
                showShareSheet = true
            }) {
                Image(systemName: "arrow.turn.up.right")
                    .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 12)
        .sheet(isPresented: $showShareSheet) {
            if let post = post {
                ShareSheet(post: post)
            }
        }
    }
}

// MARK: - Post Detail Item View
// (Moved to SevenVerse App/Views/Components/PostDetailItemView.swift)
// MARK: - Flow Layout for Hashtags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - WebView Sheet for CTA URLs

struct WebViewSheet: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            WebView(url: url)
                .navigationTitle("Learn More")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        // Configure WebView with shared cookie storage
        let config = WKWebViewConfiguration()
        
        // Enable website data store (shares cookies with Safari)
        config.websiteDataStore = .default()
        
        // Allow inline media playback
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator // Enable UI delegate for permissions
        
        // Allow media capture
        if #available(iOS 15.0, *) {
            webView.configuration.preferences.isElementFullscreenEnabled = true
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Configure request with cookies
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        
        // Load with cookie sharing enabled
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        // MARK: - Helper Methods
        
        private func topViewController() -> UIViewController? {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                return nil
            }
            
            var topController = rootViewController
            while let presented = topController.presentedViewController {
                topController = presented
            }
            return topController
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("🌐 [WebView] Started loading: \(webView.url?.absoluteString ?? "unknown")")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ [WebView] Finished loading: \(webView.url?.absoluteString ?? "unknown")")
            
            // Sync cookies back to HTTPCookieStorage
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
                print("🍪 [WebView] Synced \(cookies.count) cookies")
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ [WebView] Failed to load: \(error.localizedDescription)")
        }
        
        // Handle authentication challenges (for OAuth flows)
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            completionHandler(.performDefaultHandling, nil)
        }
        
        // MARK: - WKUIDelegate (Media Permissions)
        
        // Handle camera and microphone permissions
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView, 
                    requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                    initiatedByFrame frame: WKFrameInfo,
                    type: WKMediaCaptureType,
                    decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            
            let mediaType = type == .camera ? "camera" : (type == .microphone ? "microphone" : "camera and microphone")
            print("📸 [WebView] Media permission requested: \(mediaType) from \(origin.host)")
            
            // Grant permission automatically (iOS handles system permissions)
            decisionHandler(.grant)
        }
        
        // Handle JavaScript alerts, confirms, and prompts
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("⚠️ [WebView] Alert: \(message)")
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let viewController = topViewController() {
                viewController.present(alert, animated: true)
            } else {
                completionHandler()
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            print("❓ [WebView] Confirm: \(message)")
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            
            if let viewController = topViewController() {
                viewController.present(alert, animated: true)
            } else {
                completionHandler(false)
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            print("📝 [WebView] Prompt: \(prompt)")
            
            let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = defaultText
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(nil)
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(alert.textFields?.first?.text)
            })
            
            if let viewController = topViewController() {
                viewController.present(alert, animated: true)
            } else {
                completionHandler(nil)
            }
        }
        
        // Handle window.open() requests
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            print("🪟 [WebView] New window requested: \(navigationAction.request.url?.absoluteString ?? "unknown")")
            
            // Load in current webview instead of opening new window
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let post: Post
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Prepare share items
        var items: [Any] = []
        
        // Add caption text
        var shareText = post.caption
        
        // Add hashtags
        if !post.hashtags.isEmpty {
            let hashtagText = post.hashtags.map { "#\($0)" }.joined(separator: " ")
            shareText += "\n\n" + hashtagText
        }
        
        items.append(shareText)
        
        // Add image URL (for sharing link)
        if let imageURL = URL(string: post.imageUrl) {
            items.append(imageURL)
        }
        
        // Add CTA URL if available
        if let ctaUrlString = post.ctaUrl, let ctaURL = URL(string: ctaUrlString) {
            items.append(ctaURL)
        }
        
        // Create activity view controller
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // Exclude some activity types if needed
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks
        ]
        
        // For iPad: configure popover presentation
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = UIView()
            popover.permittedArrowDirections = []
        }
        
        // Completion handler
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                print("✅ [ShareSheet] Successfully shared via: \(activityType?.rawValue ?? "unknown")")
            } else if let error = error {
                print("❌ [ShareSheet] Share failed: \(error.localizedDescription)")
            } else {
                print("⚠️ [ShareSheet] Share cancelled")
            }
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Array Safe Subscript Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
