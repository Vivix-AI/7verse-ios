import AuthenticationServices
import Combine
import GoogleSignIn
import Supabase
import SwiftUI

enum AuthState {
    case loading
    case authenticated
    case unauthenticated
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?

    private let client = SupabaseManager.shared.client

    init() {
        Task {
            await checkSession()
        }
    }

    // MARK: - User Metadata Helpers

    var userEmail: String? {
        currentUser?.email
    }

    var userAvatarUrl: String? {
        // Google typically provides 'avatar_url' or 'picture' in user_metadata
        guard let metadata = currentUser?.userMetadata else { return nil }

        if let url = metadata["avatar_url"]?.value as? String {
            return url
        }
        if let url = metadata["picture"]?.value as? String {
            return url
        }
        return nil
    }

    func checkSession() async {
        do {
            let session = try await client.auth.session
            self.currentUser = session.user
            self.authState = .authenticated
        } catch {
            self.authState = .unauthenticated
        }
    }

    // 原生登录核心逻辑
    func signInWithGoogle() async {
        self.isLoading = true
        self.errorMessage = nil

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            self.errorMessage = "Cannot find root view controller"
            self.isLoading = false
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing ID Token"])
            }

            let session = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken
                )
            )

            self.currentUser = session.user
            self.authState = .authenticated

        } catch {
            print("Google Sign-In Error: \(error)")
            if (error as NSError).code == GIDSignInError.canceled.rawValue {
                // User canceled
            } else {
                self.errorMessage = "Login failed: \(error.localizedDescription)"
            }
        }

        self.isLoading = false
    }

    func signOut() async {
        // 1. 立即更新 UI 状态，让用户感觉是“秒退”
        self.currentUser = nil
        self.authState = .unauthenticated

        // 2. 在后台默默执行网络请求清理工作
        // 不要 await 它们，因为失败了也不影响用户视角的“已登出”
        Task {
            GIDSignIn.sharedInstance.signOut()
            try? await client.auth.signOut()
        }
    }

    func handleUrl(_ url: URL) async {
        let handled = GIDSignIn.sharedInstance.handle(url)
        if handled { return }
    }
}
