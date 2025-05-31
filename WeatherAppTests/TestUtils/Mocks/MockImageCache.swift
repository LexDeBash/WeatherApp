//
//  MockImageCache.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import Foundation
@testable import WeatherApp

/// Мок для `ImageCacheProtocol`.
/// Сохраняет и возвращает `Data` по ключу URL.
final class MockImageCache: ImageCacheProtocol {
    /// Словарь для хранения данных изображений.
    private var storage: [URL: Data] = [:]

    // MARK: - ImageCacheProtocol
    /// Возвращает сохраненные данные изображения для указанного URL, либо `nil`, если их нет.
    func imageData(for url: URL) -> Data? {
        storage[url]
    }
    
    /// Сохраняет данные изображения для указанного URL.
    func storeImageData(_ data: Data, for url: URL) {
        storage[url] = data
    }
}
