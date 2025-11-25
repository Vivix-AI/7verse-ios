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
                    // Home Icon
                    TabBarButton(icon: "play.circle", isSelected: selectedTab == .home) {
                        selectedTab = .home
                    }

                    Spacer()

                    // Create Icon
                    TabBarButton(icon: "plus.app", isSelected: selectedTab == .create) {
                        selectedTab = .create
                    }

                    Spacer()

                    // Profile Icon
                    TabBarButton(icon: "person", isSelected: selectedTab == .profile) {
                        selectedTab = .profile
                    }
                }
                .padding(.horizontal, 60) // Increased horizontal padding to bring icons closer together
                .padding(.top, 6) // Compact top padding
                .padding(.bottom, 24) // Compact bottom padding
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
                .font(.system(size: 22, weight: isSelected ? .semibold : .regular)) // Slightly smaller for compact design
                .foregroundColor(isSelected ? .black : .gray)
                .frame(width: 44, height: 40) // Reduced height for more centered look
        }
    }
}
