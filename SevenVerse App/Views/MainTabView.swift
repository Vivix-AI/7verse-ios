import SwiftUI

struct MainTabView: View {
    @StateObject private var feedViewModel = FeedViewModel()
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, create, profile
    }
    
    init() {
        // Clear standard tab bar appearance just in case we revert or mix
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content Layer
            Group {
                switch selectedTab {
                case .home:
                    FeedView(viewModel: feedViewModel)
                case .create:
                    ZStack {
                        Color(uiColor: .systemGray6).ignoresSafeArea()
                        Text("Create Post View")
                            .foregroundColor(.black)
                    }
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar Layer
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                HStack(spacing: 0) {
                    TabBarButton(icon: "play.rectangle", isSelected: selectedTab == .home) {
                        selectedTab = .home
                    }
                    
                    Spacer()
                    Spacer() // Double spacer for extra push
                    
                    TabBarButton(icon: "plus.app", isSelected: selectedTab == .create) {
                        selectedTab = .create
                    }
                    
                    Spacer()
                    Spacer() // Double spacer for extra push
                    
                    TabBarButton(icon: "person", isSelected: selectedTab == .profile) {
                        selectedTab = .profile
                    }
                }
                .padding(.horizontal, 60) // Increased horizontal padding to push items closer to center if needed, or reduce to push out
                // To increase spacing BETWEEN items, we need to reduce horizontal padding so they can spread out more, 
                // OR use fixed Spacers.
                // If the user wants "gap between icons to be larger", pushing them apart means pushing them towards edges.
                // So DECREASING padding .horizontal pushes them further apart.
                .padding(.horizontal, 20) // Reduced from 40 to 20 to allow buttons to move further apart (increasing gap)
                .padding(.top, 12)
                .padding(.bottom, 34) // Approximate safe area for iPhone X+
                .background(Color.white)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom) // Allow TabBar to extend to bottom edge
        .preferredColorScheme(.light)
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: isSelected ? .semibold : .regular)) // Slightly larger icons
                .foregroundColor(isSelected ? .black : .gray)
                .frame(width: 44, height: 44) // Larger touch target
        }
    }
}
