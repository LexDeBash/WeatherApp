//
//  NetworkSession.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import Foundation

/// Протокол абстракции сетевого клиента для тестирования `WeatherService`.
///
/// Позволяет заменить `URLSession` мок-объектом при написании юнит-тестов.
/// Используется только метод `data(from:)`, применяемый для загрузки данных по URL.
///
/// - Note: Протокол реализуется `URLSession` по умолчанию через расширение.
///
/// Пример внедрения в `WeatherService`:
/// ```swift
/// let service = WeatherService(
///     apiKey: "...",
///     session: URLSession.shared,
///     ...
/// )
/// ```
protocol NetworkSession {
    
    /// Выполняет загрузку данных по указанному URL.
    ///
    /// - Parameter url: URL ресурса.
    /// - Returns: Кортеж, содержащий полученные данные и ответ.
    /// - Throws: Ошибку, если загрузка завершилась неудачно.
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
