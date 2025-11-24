import Foundation
import UIKit

// MARK: - Cache Service (Singleton)

class CacheService {
    static let shared = CacheService()
    
    // MARK: - Memory Cache
    
    private var memoryCache = NSCache<NSString, CacheEntry>()
    
    private class CacheEntry {
        let data: Data
        let timestamp: Date
        
        init(data: Data, timestamp: Date = Foundation.Date()) {
            self.data = data
            self.timestamp = timestamp
        }
    }
    
    // MARK: - Configuration
    
    private let maxMemoryCacheSize = 50 * 1024 * 1024 // 50MB
    private let cacheExpiration: TimeInterval = 3600 // 1 hour
    
    private init() {
        memoryCache.totalCostLimit = maxMemoryCacheSize
        
        // Clear memory cache on memory warning
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.memoryCache.removeAllObjects()
            print("🗑️ [CacheService] Memory cache cleared due to memory warning")
        }
    }
    
    // MARK: - Posts Cache
    
    private let postsKey = "feed_posts"
    
    func cachePosts(_ posts: [Post]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(posts)
            
            // Memory cache
            let entry = CacheEntry(data: data)
            memoryCache.setObject(entry, forKey: postsKey as NSString, cost: data.count)
            
            // Disk cache
            try data.write(to: diskCacheURL(for: postsKey))
            
            print("✅ [CacheService] Cached \(posts.count) posts (\(data.count / 1024)KB)")
        } catch {
            print("❌ [CacheService] Failed to cache posts: \(error)")
        }
    }
    
    func getCachedPosts() -> [Post]? {
        // Try memory cache first
        if let entry = memoryCache.object(forKey: postsKey as NSString) {
            if !isExpired(entry.timestamp) {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let posts = try decoder.decode([Post].self, from: entry.data)
                    print("✅ [CacheService] Retrieved \(posts.count) posts from memory cache")
                    return posts
                } catch {
                    print("❌ [CacheService] Failed to decode memory cache: \(error)")
                }
            }
        }
        
        // Try disk cache
        let url = diskCacheURL(for: postsKey)
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("⚠️ [CacheService] No disk cache found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            // Check file modification date for expiration
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let modificationDate = attributes[.modificationDate] as? Date,
               isExpired(modificationDate) {
                print("⚠️ [CacheService] Disk cache expired")
                try? FileManager.default.removeItem(at: url)
                return nil
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let posts = try decoder.decode([Post].self, from: data)
            
            // Restore to memory cache
            let entry = CacheEntry(data: data)
            memoryCache.setObject(entry, forKey: postsKey as NSString, cost: data.count)
            
            print("✅ [CacheService] Retrieved \(posts.count) posts from disk cache")
            return posts
        } catch {
            print("❌ [CacheService] Failed to load disk cache: \(error)")
            try? FileManager.default.removeItem(at: url)
            return nil
        }
    }
    
    func clearPostsCache() {
        memoryCache.removeObject(forKey: postsKey as NSString)
        let url = diskCacheURL(for: postsKey)
        try? FileManager.default.removeItem(at: url)
        print("🗑️ [CacheService] Posts cache cleared")
    }
    
    // MARK: - Image Cache (Using URLCache)
    
    func configureImageCache() {
        // URLCache for image caching (handled by AsyncImage automatically)
        let memoryCapacity = 50 * 1024 * 1024 // 50MB
        let diskCapacity = 200 * 1024 * 1024 // 200MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        URLCache.shared = cache
        
        print("✅ [CacheService] Image cache configured (Memory: \(memoryCapacity / 1024 / 1024)MB, Disk: \(diskCapacity / 1024 / 1024)MB)")
    }
    
    // MARK: - Helpers
    
    private func isExpired(_ date: Date) -> Bool {
        return Foundation.Date().timeIntervalSince(date) > cacheExpiration
    }
    
    private func diskCacheURL(for key: String) -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let appCacheDirectory = cacheDirectory.appendingPathComponent("7verse", isDirectory: true)
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: appCacheDirectory, withIntermediateDirectories: true)
        
        return appCacheDirectory.appendingPathComponent("\(key).json")
    }
    
    // MARK: - Cache Info
    
    func getCacheSize() -> String {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let appCacheDirectory = cacheDirectory.appendingPathComponent("7verse", isDirectory: true)
        
        guard let enumerator = FileManager.default.enumerator(at: appCacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "0 KB"
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let fileSize = resourceValues.fileSize else {
                continue
            }
            totalSize += Int64(fileSize)
        }
        
        let sizeInMB = Double(totalSize) / 1024.0 / 1024.0
        if sizeInMB < 1.0 {
            return String(format: "%.0f KB", Double(totalSize) / 1024.0)
        } else {
            return String(format: "%.1f MB", sizeInMB)
        }
    }
    
    func clearAllCache() {
        memoryCache.removeAllObjects()
        
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let appCacheDirectory = cacheDirectory.appendingPathComponent("7verse", isDirectory: true)
        try? FileManager.default.removeItem(at: appCacheDirectory)
        
        URLCache.shared.removeAllCachedResponses()
        
        print("🗑️ [CacheService] All cache cleared")
    }
}

