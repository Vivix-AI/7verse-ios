import Foundation

enum Secrets {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    static var supabaseURL: String {
        string(for: "SUPABASE_URL") ?? "https://bfbitffcqlerawiikhxa.supabase.co"
    }

    static var supabaseAnonKey: String {
        string(for: "SUPABASE_ANON_KEY") ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmYml0ZmZjcWxlcmF3aWlraHhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjAzMzEsImV4cCI6MjA3MDczNjMzMX0.X911q2XAdlwtG07gmf-f30hSrF5j7OUrufYvmqbLpSw"
    }
    
    static var gcsBucketName: String {
        string(for: "GCS_BUCKET_NAME") ?? "demo-7verse"
    }
    
    static var gcpProjectId: String {
        string(for: "GCP_PROJECT_ID") ?? "vivix-465517"
    }
    
    static var campaignBaseURL: String {
        // Handle potential xcconfig escaping issues if any
        let url = string(for: "CAMPAIGN_BASE_URL") ?? "https://talking-test.vivix.work/character?charid="
        return url.replacingOccurrences(of: "https:/$()/", with: "https://")
    }
    
    // Helper to read from Info.plist or Environment
    private static func string(for key: String) -> String? {
        if let value = infoDictionary[key] as? String {
            return value
        }
        return ProcessInfo.processInfo.environment[key]
    }
}
