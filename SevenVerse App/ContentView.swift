import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .loading:
                // Match Launch Screen (White)
                Color.white.ignoresSafeArea()
            case .authenticated:
                MainTabView()
            case .unauthenticated:
                LoginView()
            }
        }
        .animation(.easeInOut, value: authViewModel.authState)
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Logo - positioned so bottom = screen center + 75pt (quarter of logo height)
                    let centerY = geometry.size.height / 2
                    let logoHeight: CGFloat = 300
                    let logoQuarterHeight: CGFloat = 75
                    let topPadding = centerY - logoHeight + logoQuarterHeight

                    Spacer()
                        .frame(height: topPadding)

                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)

                    Spacer()

                    // Login Section
                    VStack(spacing: 16) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.2)
                        } else {
                            Button(action: {
                                Task {
                                    await authViewModel.signInWithGoogle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "globe")
                                        .resizable()
                                        .frame(width: 20, height: 20)

                                    Text("Continue with Google")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 30)
                        }

                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 32)

                    // Version & Copyright Footer
                    LoginFooterView()
                        .padding(.bottom, 20)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .all)
    }
}

// MARK: - Login Footer Component

struct LoginFooterView: View {
    var body: some View {
        VStack(spacing: 8) {
            // Version
            Text("Version \(appVersion)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)

            // Copyright (no space after ©)
            Text("©\(currentYear) 7Verse AI")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
