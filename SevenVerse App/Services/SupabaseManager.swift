import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        let url = Secrets.supabaseURL
        let key = Secrets.supabaseAnonKey
        
        print("🔍 [SupabaseManager] Initializing with URL: \(url)")
        print("🔍 [SupabaseManager] Anon Key (first 20 chars): \(key.prefix(20))...")
        
        guard let supabaseURL = URL(string: url) else {
            print("❌ [SupabaseManager] FATAL: Invalid Supabase URL")
            fatalError("Invalid Supabase URL: \(url)")
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
        
        print("✅ [SupabaseManager] Client initialized successfully")
    }
}

