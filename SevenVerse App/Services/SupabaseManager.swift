import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        let url = Secrets.supabaseURL
        let key = Secrets.supabaseServiceRoleKey

        // Validate URL before using it
        guard let supabaseURL = URL(string: url),
              let host = supabaseURL.host,
              host.contains("supabase.co")
        else {
            print("❌ [SupabaseManager] Invalid Supabase URL")
            fatalError("Invalid Supabase URL: '\(url)'")
        }

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: key,
            options: SupabaseClientOptions(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
