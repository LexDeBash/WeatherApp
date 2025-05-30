//
//  ForecastCellViewModel.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

/// ViewModel для отображения прогноза в ячейке таблицы.
struct ForecastCellViewModel {

    // MARK: - Public Properties
    /// Локализованная дата
    let date: String

    /// Погодные условия
    let condition: String

    /// Средняя температура в градусах Цельсия
    let averageTemperature: String

    /// Скорость ветра км/ч
    let windSpeed: String

    /// Влажность в процентах
    let humidity: String
    
    // MARK: - Private Properties
    private let iconURL: String
    
    // MARK: - Dependencies
    private let service: WeatherServiceProtocol

    // MARK: - Initializer
    /// Создает ViewModel из модели `ForecastDay` из сетевого слоя
    /// - Parameter forecastDay: Модель прогноза для одного дня
    init(from forecastDay: ForecastDay, with service: WeatherServiceProtocol) {
        date = Date.formattedForecastDate(from: forecastDay.date)
        condition = forecastDay.dayForecast.condition.text
        averageTemperature = String(format: "%.0f°C", forecastDay.dayForecast.averageTemperature)
        windSpeed = String(format: "Wind speed: %.1f км/ч", forecastDay.dayForecast.maxWindSpeed)
        humidity = String(format: "Humidity: %d%%", forecastDay.dayForecast.averageHumidity)
        iconURL = forecastDay.dayForecast.condition.icon
        self.service = service
    }
    
    func loadIcon() async throws -> Data {
        guard let url = WeatherAPIEndpoint.conditionIcon(path: iconURL).url(with: "") else {
            throw WeatherAPIError.invalidURL
        }
        
        return try await service.fetchImageData(from: url)
    }
}



