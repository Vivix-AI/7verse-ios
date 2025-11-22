import SwiftUI

struct ProfileHeaderView: View {
    let profile: Profile
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            AsyncImage(url: URL(string: profile.avatarUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Circle().fill(Color.gray)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            // Username
            Text("@\(profile.username)")
                .font(.headline)
                .foregroundColor(.white)
            
            // Stats
            HStack(spacing: 40) {
                StatItem(value: formatCount(profile.followersCount), label: "Followers")
                StatItem(value: formatCount(profile.followingCount), label: "Following")
            }
            
            // Bio
            if let bio = profile.bio {
                Text(bio)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
    
    func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count)/1000)
        }
        return "\(count)"
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

