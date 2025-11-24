import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Universal Navigation Bar with Back Button
            AppNavigationBar(
                leftContent: .back(action: {
                    dismiss()
                })
            )
            
            ScrollView {
                Text("""
                    **Privacy Policy**
                    
                    Last updated: November 2025
                    
                    At 7Verse, we take your privacy seriously. This Privacy Policy explains how we collect, use, and protect your personal information.
                    
                    1. **Information We Collect**
                    - **Account Information**: When you sign in with Google, we collect your email address and profile picture.
                    - **Usage Data**: We collect data on how you interact with the App to improve our services.
                    
                    2. **How We Use Your Information**
                    We use your information to provide and personalize the App features, process transactions, and communicate with you about updates.
                    
                    3. **Data Sharing**
                    We do not sell your personal data to third parties. We may share data with service providers who help us operate the App (e.g., cloud hosting, analytics).
                    
                    4. **Your Rights**
                    You have the right to access, correct, or delete your personal data. You can delete your account at any time through the App settings.
                    
                    [... More legal placeholder text ...]
                    """)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
    }
}

