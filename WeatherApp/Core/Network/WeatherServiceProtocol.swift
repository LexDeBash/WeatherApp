//
//  WeatherServiceProtocol.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 28.05.2025.
//

import Foundation

/// Протокол для получения прогноза погоды
protocol WeatherServiceProtocol {
    /// Получает прогноз погоды на указанное количество дней для заданного города
    /// - Parameters:
    ///   - city: Название города (например, "Moscow")
    ///   - days: Количество дней (максимум 10, минимум 1)
    /// - Returns: Модель прогноза (`ForecastResponse`)
    func fetchForecast(for city: String, days: Int) async throws -> ForecastResponse
}

extension WeatherServiceProtocol {
    /// Загружает прогноз погоды на 5 дней (значение по умолчанию) для указанного города.
    ///
    /// Использует значение по умолчанию `days = 5`, как указано в техническом задании.
    ///
    /// - Parameter city: Название города.
    /// - Returns: Объект `ForecastResponse` с прогнозом на 5 дней.
    /// - Throws: `WeatherAPIError`, если возникает ошибка при загрузке или декодировании данных.
    func fetchForecast(for city: String) async throws -> ForecastResponse {
        try await fetchForecast(for: city, days: 5)
    }
}
