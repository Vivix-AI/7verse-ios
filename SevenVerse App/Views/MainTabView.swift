import SwiftUI

struct MainTabView: View {
    @StateObject private var feedViewModel = FeedViewModel()
    
    init() {
        // Customize Tab Bar appearance for Light Mode
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        TabView {
            // 1. Home (Video Icon)
            FeedView(viewModel: feedViewModel)
                .tabItem {
                    Image(systemName: "play.rectangle")
                }
            
            // 2. Post (Placeholder for Create functionality)
            Text("Create Post View")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .foregroundColor(.black)
                .tabItem {
                    Image(systemName: "plus.app")
                }
            
            // 3. Me (Profile)
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                }
        }
        .accentColor(.black) // Active tab color
        .preferredColorScheme(.light) // Force Light Mode
    }
}

