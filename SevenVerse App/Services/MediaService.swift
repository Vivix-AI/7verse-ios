import Foundation

// Since the database now stores full absolute URLs (e.g. GCS or Supabase links),
// this service is simplified to just validated the URL string.
class MediaService {
    static let shared = MediaService()

    func getURL(for path: String) -> URL? {
        // If the path is already a full URL, return it
        if path.lowercased().hasPrefix("http") {
            return URL(string: path)
        }

        // Fallback: If for some reason we get a relative path, we could try to fix it,
        // but ideally the DB should only have absolute URLs now.
        // For debugging/legacy support:
        if !path.isEmpty {
            return URL(string: "https://storage.googleapis.com/sofia-her-lives-media/\(path)")
        }

        return nil
    }
}
