import SwiftUI

/// A common navigation header with back button and title
struct CommonNavigationHeader: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let showBackButton: Bool
    let onBack: (() -> Void)?
    
    init(
        title: String,
        showBackButton: Bool = true,
        onBack: (() -> Void)? = nil
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.onBack = onBack
    }
    
    var body: some View {
        HStack {
            if showBackButton {
                Button(action: {
                    if let onBack = onBack {
                        onBack()
                    } else {
                        dismiss()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            // Balance the layout
            if showBackButton {
                Color.clear
                    .frame(width: 70)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - View Extension for Easy Usage

extension View {
    /// Adds a common navigation header to the view
    func commonNavigationHeader(
        title: String,
        showBackButton: Bool = true,
        onBack: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 0) {
            CommonNavigationHeader(
                title: title,
                showBackButton: showBackButton,
                onBack: onBack
            )
            Divider()
            self
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CommonNavigationHeader(title: "Privacy Policy")
        Spacer()
    }
}

