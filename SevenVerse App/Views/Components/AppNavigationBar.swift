import SwiftUI

// MARK: - App Navigation Bar (Universal)

struct AppNavigationBar: View {
    let leftContent: LeftContent
    let showSearch: Bool
    let showNotifications: Bool
    let onSearchTap: (() -> Void)?
    let onNotificationTap: (() -> Void)?
    
    enum LeftContent {
        case logo
        case icon
        case back(action: (() -> Void)?)
    }
    
    init(
        leftContent: LeftContent = .logo,
        showSearch: Bool = false,
        showNotifications: Bool = false,
        onSearchTap: (() -> Void)? = nil,
        onNotificationTap: (() -> Void)? = nil
    ) {
        self.leftContent = leftContent
        self.showSearch = showSearch
        self.showNotifications = showNotifications
        self.onSearchTap = onSearchTap
        self.onNotificationTap = onNotificationTap
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Content
            switch leftContent {
            case .logo:
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32)
                    .padding(.leading, 6)
                
            case .icon:
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .padding(.leading, 6)
                
            case .back(let action):
                Button(action: {
                    if let action = action {
                        action()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                .padding(.leading, 4)
            }
            
            Spacer()
            
            // Right Actions
            HStack(spacing: 12) {
                if showNotifications {
                    Button(action: {
                        onNotificationTap?()
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                }
                
                if showSearch {
                    Button(action: {
                        onSearchTap?()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.trailing, 12)
        }
        .frame(height: 44)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - View Extension for Easy Usage

extension View {
    func appNavigationBar(
        leftContent: AppNavigationBar.LeftContent = .logo,
        showSearch: Bool = false,
        showNotifications: Bool = false,
        onSearchTap: (() -> Void)? = nil,
        onNotificationTap: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 0) {
            AppNavigationBar(
                leftContent: leftContent,
                showSearch: showSearch,
                showNotifications: showNotifications,
                onSearchTap: onSearchTap,
                onNotificationTap: onNotificationTap
            )
            self
        }
    }
}
