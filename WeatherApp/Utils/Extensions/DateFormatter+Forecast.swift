//
//  DateFormatter+Forecast.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

extension Date {
    /// Парсит строку "yyyy-MM-dd" и возвращает дату в формате "Fri, May 29" с учётом локали.
    /// - Parameter source: Строка даты в формате "yyyy-MM-dd"
    /// - Returns: Отформатированная строка даты или исходная строка при неуспехе парсинга.
    static func formattedForecastDate(from source: String) -> String {
        // Создаём ISO8601‐парсер для полной даты с временем UTC
        let isoParser = ISO8601DateFormatter()
        isoParser.formatOptions = [.withFullDate]
        
        // Добавляем временную часть к дате API
        let isoString = source + "T00:00:00Z"
        
        // Парсим дату
        guard let date = isoParser.date(from: isoString) else {
            return source
        }
        
        // Формируем стиль вывода: сокращённый день недели, число и месяц
        let style = Date.FormatStyle()
            .weekday(.wide)
            .day(.defaultDigits)
            .month(.wide)
            .locale(.current)
        
        return date.formatted(style)
    }
}
