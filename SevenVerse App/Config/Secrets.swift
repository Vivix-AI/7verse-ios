import Foundation

enum Secrets {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    // MARK: - Supabase Configuration
    
    static var supabaseURL: String {
        string(for: "SUPABASE_URL") ?? "https://bfbitffcqlerawiikhxa.supabase.co"
    }

    /// Anon Key: For public frontend access, restricted by RLS
    static var supabaseAnonKey: String {
        string(for: "SUPABASE_ANON_KEY") ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmYml0ZmZjcWxlcmF3aWlraHhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjAzMzEsImV4cCI6MjA3MDczNjMzMX0.X911q2XAdlwtG07gmf-f30hSrF5j7OUrufYvmqbLpSw"
    }
    
    /// Service Role Key: Bypasses RLS, for backend services or iOS app
    static var supabaseServiceRoleKey: String {
        string(for: "SUPABASE_SERVICE_ROLE_KEY") ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmYml0ZmZjcWxlcmF3aWlraHhhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTE2MDMzMSwiZXhwIjoyMDcwNzM2MzMxfQ.4WnDRxJAhA6p1gFR2XB-_9jMC4GMcxcBh78HvJPtrbE"
    }
    
    /// Database URL (optional, for direct database connection)
    static var databaseURL: String? {
        string(for: "DATABASE_URL")
    }
    
    // MARK: - Google Cloud Platform
    
    static var gcpProjectId: String {
        string(for: "GCP_PROJECT_ID") ?? "vivix-465517"
    }
    
    static var gcsBucketName: String {
        string(for: "GCS_BUCKET_NAME") ?? "7verse-dev-media-public"
    }
    
    /// Google Service Account JSON (Base64 encoded)
    static var gcpServiceAccountJsonBase64: String? {
        string(for: "GCP_SA_JSON_BASE64")
    }
    
    /// Decoded Google Service Account JSON
    static var gcpServiceAccountJson: Data? {
        guard let base64 = gcpServiceAccountJsonBase64,
              let data = Data(base64Encoded: base64) else {
            return nil
        }
        return data
    }
    
    // MARK: - Other Services
    
    static var campaignBaseURL: String {
        let url = string(for: "CAMPAIGN_BASE_URL") ?? "https://talking-test.vivix.work/character?charid="
        return url.replacingOccurrences(of: "https:/$()/", with: "https://")
    }
    
    // MARK: - Helper
    
    private static func string(for key: String) -> String? {
        if let value = infoDictionary[key] as? String {
            return value
        }
        return ProcessInfo.processInfo.environment[key]
    }
}
