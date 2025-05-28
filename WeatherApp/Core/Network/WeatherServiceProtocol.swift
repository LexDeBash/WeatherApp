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
