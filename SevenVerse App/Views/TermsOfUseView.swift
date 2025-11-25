import SwiftUI

struct TermsOfUseView: View {
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
                **Terms of Use**

                Last updated: November 2025

                Welcome to 7Verse! By accessing or using our mobile application, you agree to be bound by these terms.

                1. **Acceptance of Terms**
                By creating an account or using the App, you agree to comply with these Terms of Use. If you do not agree, please do not use the App.

                2. **User Accounts**
                You are responsible for maintaining the confidentiality of your login credentials. You agree to notify us immediately of any unauthorized use of your account.

                3. **Content Guidelines**
                You retain ownership of the content you post. However, by posting, you grant us a non-exclusive, royalty-free license to use, display, and distribute your content within the App. You agree not to post content that is illegal, harmful, or violates the rights of others.

                4. **Termination**
                We reserve the right to suspend or terminate your account at any time for violations of these Terms.

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
