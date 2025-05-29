//
//  DateFormatter+Forecast.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

extension DateFormatter {
    static let forecastDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // формат даты от API
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let dayLabel: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}

extension DateFormatter {
    func string(from source: String) -> String {
        guard let date = DateFormatter.forecastDate.date(from: source) else {
            return source
        }
        return string(from: date)
    }
}
