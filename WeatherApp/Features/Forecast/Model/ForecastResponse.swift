//
//  ForecastResponse.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

struct ForecastResponse: Decodable, Equatable {
    let forecast: Forecast
}

struct Forecast: Decodable, Equatable {
    let days: [ForecastDay]
}

private extension Forecast {
    enum CodingKeys: String, CodingKey {
        case days = "forecastday"
    }
}

struct ForecastDay: Decodable, Equatable {
    let date: String
    let dayForecast: DayForecast
}

private extension ForecastDay {
    enum CodingKeys: String, CodingKey {
        case date
        case dayForecast = "day"
    }
}

struct DayForecast: Decodable, Equatable {
    let averageTemperature: Double
    let maxWindSpeed: Double
    let averageHumidity: Double
    let condition: WeatherCondition
}

private extension DayForecast {
    enum CodingKeys: String, CodingKey {
        case averageTemperature = "avgtemp_c"
        case maxWindSpeed = "maxwind_kph"
        case averageHumidity = "avghumidity"
        case condition
    }
}

struct WeatherCondition: Decodable, Equatable {
    let text: String
    let icon: String
}
