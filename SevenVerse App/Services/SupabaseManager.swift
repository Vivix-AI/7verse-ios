import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        let url = Secrets.supabaseURL
        let key = Secrets.supabaseServiceRoleKey // Using Service Role Key to bypass RLS
        
        print("🔍 [SupabaseManager] Initializing with URL: \(url)")
        print("🔍 [SupabaseManager] Using Service Role Key (first 20 chars): \(key.prefix(20))...")
        print("⚠️ [SupabaseManager] Service Role Key bypasses RLS - use with caution!")
        
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
        
        print("✅ [SupabaseManager] Client initialized successfully with Service Role Key")
    }
}

