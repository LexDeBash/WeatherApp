//
//  ImageCacheProtocol.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import Foundation

/// Протокол для кэширования бинарных данных изображений.
protocol ImageCacheProtocol {
    /// Возвращает закэшированные данные изображения для указанного URL, если они есть.
    /// - Parameter url: URL изображения.
    /// - Returns: Двоичные данные изображения или `nil`, если кэш отсутствует.
    func imageData(for url: URL) -> Data?

    /// Сохраняет данные изображения в кэш по заданному URL.
    /// - Parameters:
    ///   - data: Двоичные данные изображения.
    ///   - url: URL, с которым связано изображение.
    func storeImageData(_ data: Data, for url: URL)
}
