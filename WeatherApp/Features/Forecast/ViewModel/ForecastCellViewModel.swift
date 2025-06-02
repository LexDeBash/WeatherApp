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
    
    /// URL адрес иконки погодных условий
    let iconURL: URL?

    // MARK: - Initializer
    /// Создает ViewModel из модели `ForecastDay` из сетевого слоя
    /// - Parameter forecastDay: Модель прогноза для одного дня
    init(from forecastDay: ForecastDay) {
        date = Date.formattedForecastDate(from: forecastDay.date)
        condition = forecastDay.dayForecast.condition.text
        averageTemperature = String(format: "%.0f°C", forecastDay.dayForecast.averageTemperature)
        windSpeed = String(format: "Wind speed: %.1f км/ч", forecastDay.dayForecast.maxWindSpeed)
        humidity = "Humidity: \(forecastDay.dayForecast.averageHumidity.formatted())%"
        
        let iconPath = forecastDay.dayForecast.condition.icon
        
        if iconPath.starts(with: "//") {
            iconURL = URL(string: "https:\(iconPath)")
        } else {
            iconURL = nil
        }
    }
}
