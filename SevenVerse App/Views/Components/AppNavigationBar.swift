import SwiftUI

// MARK: - App Navigation Bar (Universal)

struct AppNavigationBar: View {
    let leftContent: LeftContent
    let showSearch: Bool
    let showNotifications: Bool
    let showShare: Bool
    let backgroundColor: Color
    let iconColor: Color
    let onSearchTap: (() -> Void)?
    let onNotificationTap: (() -> Void)?
    let onShareTap: (() -> Void)?
    
    enum LeftContent {
        case logo
        case icon
        case back(action: (() -> Void)?)
    }
    
    init(
        leftContent: LeftContent = .logo,
        showSearch: Bool = false,
        showNotifications: Bool = false,
        showShare: Bool = false,
        backgroundColor: Color = .white,
        iconColor: Color = .black,
        onSearchTap: (() -> Void)? = nil,
        onNotificationTap: (() -> Void)? = nil,
        onShareTap: (() -> Void)? = nil
    ) {
        self.leftContent = leftContent
        self.showSearch = showSearch
        self.showNotifications = showNotifications
        self.showShare = showShare
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.onSearchTap = onSearchTap
        self.onNotificationTap = onNotificationTap
        self.onShareTap = onShareTap
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
                        .foregroundColor(iconColor)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .padding(.leading, 4)
            }
            
            Spacer()
            
            // Right Actions
            HStack(spacing: 4) {
                if showShare {
                    Button(action: {
                        onShareTap?()
                    }) {
                        Image(systemName: "arrow.turn.up.right")
                            .font(.system(size: 20))
                            .foregroundColor(iconColor)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
                
                if showNotifications {
                    Button(action: {
                        onNotificationTap?()
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(iconColor)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
                
                if showSearch {
                    Button(action: {
                        onSearchTap?()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(iconColor)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
            .padding(.trailing, 4)
        }
        .frame(height: 44)
        .background(backgroundColor)
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
