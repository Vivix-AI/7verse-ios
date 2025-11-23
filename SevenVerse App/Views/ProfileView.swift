import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        // 移除了 NavigationView，因为 MainTabView 外部或者内容不需要额外的导航栈包裹（如果不需要跳转）
        // 或者如果需要跳转，确保 NavigationView 能够正常渲染。
        // 黑屏原因通常是：
        // 1. List 在全黑背景下默认是透明的，而下面没有颜色。
        // 2. 或者是 NavigationView 嵌套问题。
        // 3. 或者是数据为空导致渲染了空 View。
        
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6).ignoresSafeArea()
                
                List {
                    // Header Section
                    Section {
                        HStack(spacing: 16) {
                            if let avatarUrl = authViewModel.userAvatarUrl, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    default:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authViewModel.userEmail ?? "Guest")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text("Google Account")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color(uiColor: .systemGray6))
                    }
                    
                    // General Settings
                    Section {
                        NavigationLink("Terms of Use") {
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
                            .navigationBarHidden(true) 
                            .background(Color.white)
                        }
                        
                        NavigationLink("Privacy Policy") {
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
                            .navigationBarHidden(true)
                            .background(Color.white)
                        }
                        
                        HStack {
                            Text("Version")
                                .foregroundColor(.black)
                            Spacer()
                            Text(appVersion)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color(uiColor: .systemGray6))
                    
                    // Actions
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await authViewModel.signOut()
                            }
                        } label: {
                            Text("Sign Out")
                        }
                    }
                    .listRowBackground(Color(uiColor: .systemGray6))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.light)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
