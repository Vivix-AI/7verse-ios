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
        ZStack {
            // 1. Logo Layer - Bottom aligned to CenterY
            VStack {
                Spacer()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 2. Action Layer - Button at bottom
            VStack {
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
                        .background(Color.black) // Keep button black for contrast
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
                .padding(.bottom, 50)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
