import SwiftUI
import AVKit

struct GreetingsVideoPlayer: View {
    let videoURL: URL
    let onDismiss: () -> Void
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap to skip
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                // Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(width: 300, height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.5), radius: 20)
                } else {
                    // Loading state
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                        .frame(width: 300, height: 400)
                }
                
                // Skip button
                Button(action: {
                    onDismiss()
                }) {
                    HStack(spacing: 8) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = 0.8
        
        // Observe when video finishes
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            // Auto dismiss when video ends
            onDismiss()
        }
        
        // Start playing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            player?.play()
            isPlaying = true
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
}

