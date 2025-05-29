//
//  ForecastResponse.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

struct ForecastResponse: Decodable {
    let forecast: Forecast
}

struct Forecast: Decodable {
    let forecastDay: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let day: DayForecast
}

struct DayForecast: Decodable {
    let avgtempC: Double
    let maxwindKph: Double
    let avghumidity: Double
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let icon: String
}
