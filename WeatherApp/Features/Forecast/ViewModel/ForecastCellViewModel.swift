//
//  ForecastCellViewModel.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

struct ForecastCellViewModel {
    let date: String
    let description: String
    let iconURL: URL?
    let averageTemperature: String
    let windSpeed: String
    let humidity: String
    
    init(from model: ForecastDay) {
        // Пример: "2025-05-29" → "Чт, 29 мая"
        date = DateFormatter.dayLabel.string(from: model.date)
        
        description = model.day.condition.text
        
        iconURL = URL(string: "https:\(model.day.condition.icon)")
        
        averageTemperature = "\(Int(round(model.day.avgtempC)))°C"
        windSpeed = "\(Int(round(model.day.maxwindKph))) км/ч"
        humidity = "\(Int(round(model.day.avghumidity))) %"
    }
}
