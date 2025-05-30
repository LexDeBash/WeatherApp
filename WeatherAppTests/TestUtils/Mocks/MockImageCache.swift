//
//  MockImageCache.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import Foundation
@testable import WeatherApp

final class MockImageCache: ImageCacheProtocol {
    private var cache: [URL: Data] = [:]

    func imageData(for url: URL) -> Data? {
        return cache[url]
    }

    func storeImageData(_ data: Data, for url: URL) {
        cache[url] = data
    }
}
