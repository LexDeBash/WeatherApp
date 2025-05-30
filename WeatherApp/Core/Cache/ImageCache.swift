//
//  ImageCache.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import Foundation

/// Реализация `ImageDataCaching` с использованием `NSCache`.
final class ImageCache: ImageCacheProtocol {
    
    /// Singleton-экземпляр кэша изображений.
    static let shared = ImageCache()
    
    private let cache = NSCache<NSURL, NSData>()
    
    private init() {}
    
    func imageData(for url: URL) -> Data? {
        cache.object(forKey: url as NSURL) as Data?
    }
    
    func storeImageData(_ data: Data, for url: URL) {
        cache.setObject(data as NSData, forKey: url as NSURL)
    }
}
