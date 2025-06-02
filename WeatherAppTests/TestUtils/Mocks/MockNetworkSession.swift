//
//  MockNetworkSession.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//


import Foundation
@testable import WeatherApp

/// Расширяемый мок для `NetworkSession`. Позволяет задавать:
/// - тело ответа (`data`)
/// - HTTP-статус (`statusCode`)
/// - заголовки ответа (`headerFields`)
/// - эмулировать ошибку сети (`error`)
/// - (при необходимости) расширять логику: задержки, логирование и т.д.
final class MockNetworkSession: NetworkSession {
    
    // MARK: - Private Properties
    /// Данные, которые вернёт мок (по умолчанию — пустой `Data()`)
    private let data: Data?
    
    /// Словарь заголовков для формирования HTTPURLResponse (по умолчанию — пустой)
    private let headerFields: [String: String]?
    
    /// HTTP-статус, который нужно эмулировать (по умолчанию — 200)
    private let statusCode: Int
    
    /// Ошибка, которую нужно бросить вместо успешного ответа (по умолчанию — `nil`)
    private let error: Error?

    /// Сохраняет последний URL, переданный в data(from:)
    private(set) var lastURL: URL?
    
    // MARK: - Initializer
    /// Инициализирует мок с заданными параметрами.
    ///
    /// - Parameters:
    ///   - data: Данные, которые вернёт мок. Если `nil`, вернётся пустой `Data()`.
    ///   - statusCode: HTTP-статус для формирования `HTTPURLResponse` (по умолчанию — 200).
    ///   - headerFields: Заголовки для `HTTPURLResponse` (по умолчанию — `nil` -> без заголовков).
    ///   - error: Если не `nil`, мок бросит эту ошибку вместо возврата `(Data, URLResponse)`.
    init(
        data: Data? = nil,
        statusCode: Int = 200,
        headerFields: [String: String]? = nil,
        error: Error? = nil
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headerFields = headerFields
        self.error = error
    }
    
    // MARK: - NetworkSession
    /// Эмуляция загрузки данных через `NetworkSession`.
    ///
    /// - Parameter url: URL, по которому выполняется запрос.
    /// - Returns: Кортеж `(Data, URLResponse)` или бросает ошибку, если задано `error`.
    func data(from url: URL) async throws -> (Data, URLResponse) {
        lastURL = url
        if let error {
            throw error
        }
        
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headerFields
        )!
        
        return (data ?? Data(), httpResponse)
    }
}
