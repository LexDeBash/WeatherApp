//
//  MockForecastCache.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

@testable import WeatherApp

/// Мок для `ForecastCacheProtocol`.
/// Сохраняет и возвращает `ForecastResponse` по ключу города.
final class MockForecastCache: ForecastCacheProtocol {
    /// Словарь для хранения закэшированных прогнозов.
    private var storage: [String: ForecastResponse] = [:]

    // MARK: - ForecastCacheProtocol
    /// Сохраняет прогноз для указанного города.
    func set(_ forecast: ForecastResponse, for city: String) {
        storage[city] = forecast
    }

    /// Возвращает сохранённый прогноз для указанного города, либо `nil`, если его нет.
    func forecast(for city: String) -> ForecastResponse? {
        storage[city]
    }

    /// Удаляет прогноз для указанного города
    func removeForecast(for city: String) {
        storage.removeValue(forKey: city)
    }

    /// Удаляет все записи из хранилища
    func removeAll() {
        storage.removeAll()
    }
}
