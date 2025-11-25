import Foundation

class DataLoader {
    static func loadPosts() -> [Post] {
        guard
            let url = Bundle.main.url(
                forResource: "posts-config",
                withExtension: "json"
            )
        else {
            print("JSON file not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // Decode directly to [Post] since I flattened the JSON structure in previous step
            // Wrappers like "posts": [...] might be needed if the JSON file still has root object
            // Let's assume I updated the JSON to have a "posts" root key or just array.
            // Checking previous step: The JSON has a root object with "posts" key.

            let response = try decoder.decode(
                PostResponseWrapper.self,
                from: data
            )
            return response.posts
        } catch {
            print("Error decoding local posts: \(error)")
            return []
        }
    }
}

// Helper wrapper for the local JSON structure
struct PostResponseWrapper: Codable {
    let posts: [Post]
}
