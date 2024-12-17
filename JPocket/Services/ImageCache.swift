//
//  ImageCache.swift
//  JPocket
//
//  Created by Ruby on 15/12/2024.
//

import Foundation
import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure cache
        cache.countLimit = 100 // Maximum number of images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func image(for url: URL) -> UIImage? {
        let key = url.absoluteString as NSString
        
        // Check memory cache first
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        // Check disk cache
        let filePath = cacheDirectory.appendingPathComponent(key.hash.description)
        if let data = try? Data(contentsOf: filePath),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: key)
            return image
        }
        
        return nil
    }
    
    func cache(image: UIImage, for url: URL) {
        let key = url.absoluteString as NSString
        
        // Cache in memory
        cache.setObject(image, forKey: key)
        
        // Cache to disk
        let filePath = cacheDirectory.appendingPathComponent(key.hash.description)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: filePath)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
} 
