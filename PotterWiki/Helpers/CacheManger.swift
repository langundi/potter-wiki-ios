//
//  CacheManager.swift
//  PotterWiki
//
//  Created by Ziqa on 18/05/26.
//

import Foundation

final class CacheManager {
    
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.potterwiki.cache", attributes: .concurrent)
    private var cacheFileURL: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "NetworkCache")
    }
    
    init() {
        try? fileManager.createDirectory(at: cacheFileURL, withIntermediateDirectories: true)
    }
    
    
    /// Setup cache for object.
    /// - Parameters:
    ///   - object: Cached value.
    ///   - key: Cache key.
    ///   - expiry: Cache expiry time.
    func set<T: Codable>(_ object: T, forKey key: String, expiry: CacheExpiry = .days(7)) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let wrapper = CacheWrapper(data: object, timestamp: Date(), expiry: expiry.timeInterval)
            guard let encoded = try? JSONEncoder().encode(wrapper) else { return }
            let url = self.cacheURL(forKey: key)
            try? encoded.write(to: url, options: .atomic)
        }
    }
    
    
    /// Get cached object.
    /// - Parameter key: Cache key.
    /// - Returns: Value for cache key.
    func get<T: Codable>(forKey key: String) -> T? {
        queue.sync {
            let url = cacheURL(forKey: key)
            guard let data = try? Data(contentsOf: url),
                let wrapper = try? JSONDecoder().decode(CacheWrapper<T>.self, from: data) else {
                return nil
            }
            
            guard !wrapper.isExpired else {
                remove(forKey: key)
                return nil
            }
            
            return wrapper.data
        }
    }
    
    
    /// Removes cache for cache key.
    /// - Parameter key: Cache key.
    func remove(forKey key: String) {
        queue.async(flags: .barrier) {
            try? self.fileManager.removeItem(at: self.cacheURL(forKey: key))
        }
    }
    
    
    /// Clears all cache from disk.
    func clearAll() {
        queue.async(flags: .barrier) {
            try? self.fileManager.removeItem(at: self.cacheFileURL)
            try? self.fileManager.createDirectory(at: self.cacheFileURL, withIntermediateDirectories: true)
        }
    }
    
    
    /// Make URL for cache key.
    /// - Parameter key: Cache key.
    /// - Returns: Cache URL.
    private func cacheURL(forKey key: String) -> URL {
        // sanitize key to be safe as a filename
        let sanitized = key.components(separatedBy: .alphanumerics.inverted).joined(separator: "_")
        return cacheFileURL.appendingPathComponent(sanitized)
    }
}

// MARK: - Supporting Types
nonisolated
private struct CacheWrapper<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let expiry: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > expiry
    }
}

enum CacheExpiry {
    case seconds(TimeInterval)
    case minutes(TimeInterval)
    case hours(TimeInterval)
    case days(TimeInterval)
    case never
    
    var timeInterval: TimeInterval {
        switch self {
        case .seconds(let s): return s
        case .minutes(let m): return m * 60
        case .hours(let h): return h * 3600
        case .days(let d): return d * 86400
        case .never: return .infinity
        }
    }
}
