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
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Offset y by -100 (half of height) to make bottom align with center
            // Or simply use an alignment guide if we want to be precise.
            // The easiest way to match LaunchScreen "Bottom -> CenterY" constraint:
            // Place it in a VStack with Spacer, then offset it up by half its height? No.
            // LaunchScreen constraint: Image.Bottom == Superview.CenterY.
            // This means the entire image is ABOVE the center line.
            
            // In SwiftUI ZStack(alignment: .center) puts the center of image at center of screen.
            // To align bottom to center: offset y = -height/2
            .offset(y: -100)
            
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
