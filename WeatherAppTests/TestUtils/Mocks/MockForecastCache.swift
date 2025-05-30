//
//  MockForecastCache.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

@testable import WeatherApp

final class MockForecastCache: ForecastCacheProtocol {
    private var store: [String: ForecastResponse] = [:]

    func set(_ forecast: ForecastResponse, for city: String) {
        store[city] = forecast
    }

    func forecast(for city: String) -> ForecastResponse? {
        store[city]
    }

    func removeForecast(for city: String) {
        store.removeValue(forKey: city)
    }

    func removeAll() {
        store.removeAll()
    }
}
