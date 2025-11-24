import SwiftUI

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
                    Button("Close") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
            }
        } else {
            // Main content
            PostDetailCarouselView(
                groupedPosts: groupedPosts,
                initialProfileIndex: initialIndices.profile,
                initialPostIndex: initialIndices.post,
                onDismiss: {
                    isPresented = false
                }
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Post Detail Carousel View

struct PostDetailCarouselView: View {
    let groupedPosts: [[Post]]
    let initialProfileIndex: Int
    let initialPostIndex: Int
    let onDismiss: () -> Void
    
    @State private var currentProfileIndex: Int
    @State private var currentPostIndices: [Int]
    
    init(groupedPosts: [[Post]], initialProfileIndex: Int, initialPostIndex: Int, onDismiss: @escaping () -> Void) {
        self.groupedPosts = groupedPosts
        self.initialProfileIndex = initialProfileIndex
        self.initialPostIndex = initialPostIndex
        self.onDismiss = onDismiss
        
        // Initialize State
        _currentProfileIndex = State(initialValue: initialProfileIndex)
        
        // Initialize array of indices
        var indices = Array(repeating: 0, count: groupedPosts.count)
        if indices.indices.contains(initialProfileIndex) {
            indices[initialProfileIndex] = initialPostIndex
        }
        _currentPostIndices = State(initialValue: indices)
    }
    
    private var currentPost: Post? {
        guard groupedPosts.indices.contains(currentProfileIndex) else { return nil }
        let posts = groupedPosts[currentProfileIndex]
        let postIndex = currentPostIndices[currentProfileIndex]
        guard posts.indices.contains(postIndex) else { return nil }
        return posts[postIndex]
    }
    
    private var currentProfilePosts: [Post] {
        guard groupedPosts.indices.contains(currentProfileIndex) else { return [] }
        return groupedPosts[currentProfileIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Use GeometryReader + DragGesture for vertical profile switching
            GeometryReader { geometry in
                ZStack {
                    // Current Profile's Horizontal TabView
                    if groupedPosts.indices.contains(currentProfileIndex) {
                        TabView(selection: Binding(
                            get: { currentPostIndices[currentProfileIndex] },
                            set: { newValue in
                                currentPostIndices[currentProfileIndex] = newValue
                            }
                        )) {
                            ForEach(0..<groupedPosts[currentProfileIndex].count, id: \.self) { postIndex in
                                PostDetailItemView(post: groupedPosts[currentProfileIndex][postIndex])
                                    .tag(postIndex)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let verticalMovement = value.translation.height
                            let horizontalMovement = abs(value.translation.width)
                            
                            // Only process vertical gestures (ignore if horizontal swipe detected)
                            if abs(verticalMovement) > horizontalMovement && abs(verticalMovement) > 50 {
                                withAnimation {
                                    if verticalMovement < 0 {
                                        // Swipe up - next profile
                                        if currentProfileIndex < groupedPosts.count - 1 {
                                            currentProfileIndex += 1
                                        }
                                    } else {
                                        // Swipe down - previous profile
                                        if currentProfileIndex > 0 {
                                            currentProfileIndex -= 1
                                        }
                                    }
                                }
                            }
                        }
                )
            }
            .ignoresSafeArea()
            
            // UI Overlays
            VStack(spacing: 0) {
                // Top Navigation Bar
                PostDetailNavigationBar(
                    post: currentPost,
                    onBackTapped: onDismiss
                )
                
                Spacer()
                
                // Bottom Page Indicator
                if currentProfilePosts.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<currentProfilePosts.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPostIndices[currentProfileIndex] ? Color.white : Color.white.opacity(0.4))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

// MARK: - Post Detail Navigation Bar

struct PostDetailNavigationBar: View {
    let post: Post?
    let onBackTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Back Button
            Button(action: onBackTapped) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            // Profile Info
            if let profile = post?.profile {
                HStack(spacing: 8) {
                    // Avatar
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
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                    
                    // Name
                    Text(profile.profileName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            
            Spacer()
        }
        .frame(height: 44) // Same height as AppNavigationBar
        .padding(.horizontal, 12)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.5), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80) // Extend gradient for better visibility
        )
    }
}

// MARK: - Post Detail Item View (Immersive with Blur Background)

struct PostDetailItemView: View {
    let post: Post
    @State private var showInteraction = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Blurred Background Layer (use thumbnail for faster load)
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
                .clipped()
                .ignoresSafeArea()
                
                // Foreground Image (High-resolution original, Aspect Fit)
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
                
                // Tap to Interact Button (Center)
                VStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            showInteraction.toggle()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: showInteraction ? "chevron.down" : "hand.tap")
                                .font(.system(size: 13, weight: .semibold))
                            Text(showInteraction ? "Hide Details" : "Tap to Interact")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial.opacity(0.3))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                
                // Content Overlay
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    
                    // Bottom Content Area
                    VStack(alignment: .leading, spacing: 12) {
                        // Views and Premium Badge
                        HStack(spacing: 8) {
                            // Views
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 12))
                                Text(post.displayViews)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        
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
                        
                        Spacer()
                    }
                    
                    // Caption
                    Text(post.caption)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    // Hashtags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(post.hashtags, id: \.self) { tag in
                                Text("#\(tag)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        
                        // Interaction Panel (CTA)
                        if showInteraction {
                    if let ctaUrl = post.ctaUrl, let url = URL(string: ctaUrl) {
                        Link(destination: url) {
                            HStack {
                                Text("Learn More")
                                            .font(.system(size: 15, weight: .semibold))
                                Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .ignoresSafeArea()
    }
}

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
