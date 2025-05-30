//
//  WeatherAPIEndpoint.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

enum WeatherAPIEndpoint {
    case forecast(city: String, days: Int)
    case conditionIcon(path: String)
    
    func url(with apiKey: String) -> URL? {
        switch self {
        case .forecast(let city, let days):
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.weatherapi.com"
            components.path = "/v1/forecast.json"
            components.queryItems = [
                URLQueryItem(name: "q", value: city),
                URLQueryItem(name: "days", value: "\(days)"),
                URLQueryItem(name: "key", value: apiKey)
            ]
            return components.url
        case .conditionIcon(let path):
            return URL(string: "https:\(path)")
        }
    }
}
