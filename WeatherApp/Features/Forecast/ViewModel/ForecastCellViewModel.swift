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
    /// Отформатированная дата (например, "Чт, 29 мая")
    let dateText: String

    /// Описание погодного условия
    let conditionText: String

    /// URL иконки погодного условия
    let iconURL: URL?

    /// Отображаемая средняя температура с единицами (например, "23°C")
    let avgTemperatureText: String

    /// Отображаемая скорость ветра с единицами (например, "15.2 км/ч")
    let windSpeedText: String

    /// Отображаемая влажность с единицами (например, "60%")
    let humidityText: String

    // MARK: - Initializer
    /// Создает ViewModel из модели `ForecastDay` из сетевого слоя
    /// - Parameter model: Модель прогноза для одного дня
    init(from model: ForecastDay) {
        // Парсим и форматируем дату через Date расширение
        dateText = Date.formattedForecastDate(from: model.date)

        // Текстовое описание погодных условий
        conditionText = model.day.condition.text

        // URL иконки погодных условий
        iconURL = URL(string: "https:\(model.day.condition.icon)")

        // Средняя температура с единицами
        avgTemperatureText = String(format: "%.0f°C", model.day.avgtempC)

        // Скорость ветра с единицами
        windSpeedText = String(format: "%.1f км/ч", model.day.maxwindKph)

        // Влажность с единицами
        humidityText = String(format: "%d%%", model.day.avghumidity)
    }
}



