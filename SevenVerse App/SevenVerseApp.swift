import SwiftUI

@main
struct SevenVerseApp: App {
    // Create the AuthViewModel at the root level
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Configure cache on app launch
        CacheService.shared.configureImageCache()
        print("✅ [App] Cache configured")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel) // Inject into the environment
                .onOpenURL { url in
                    // Handle the OAuth callback deep link
                    Task {
                        await authViewModel.handleUrl(url)
                    }
                }
        }
    }
}
