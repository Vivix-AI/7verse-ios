import SwiftUI

struct SkeletonPostCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Skeleton Image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .shimmer(isAnimating: isAnimating)
            
            VStack(alignment: .leading, spacing: 8) {
                // Skeleton Caption
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .shimmer(isAnimating: isAnimating)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 40)
                    .shimmer(isAnimating: isAnimating)
                
                // Skeleton Profile Row
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 16, height: 16)
                        .shimmer(isAnimating: isAnimating)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 10)
                        .shimmer(isAnimating: isAnimating)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 10)
                        .shimmer(isAnimating: isAnimating)
                }
            }
            .padding(10)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    let isAnimating: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isAnimating ? 200 : -200)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
            )
            .clipped()
    }
}

extension View {
    func shimmer(isAnimating: Bool) -> some View {
        modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

