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
                            TermsOfUseView()
                        }
                        
                        NavigationLink("Privacy Policy") {
                            PrivacyPolicyView()
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
