//
//  ForecastCache.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import Foundation

final class ForecastCache: ForecastCacheProtocol {
    private let ttl: TimeInterval
    private var storage: [String: Entry] = [:]
    private let lock = NSLock()

    init(ttl: TimeInterval = 1800) {
        self.ttl = ttl
    }

    func set(_ forecast: ForecastResponse, for city: String) {
        lock.lock()
        defer { lock.unlock() }

        let expiration = Date().addingTimeInterval(ttl)
        storage[city.lowercased()] = Entry(forecast: forecast, expiration: expiration)
    }

    func forecast(for city: String) -> ForecastResponse? {
        lock.lock()
        defer { lock.unlock() }

        guard let entry = storage[city.lowercased()] else { return nil }

        if entry.isExpired {
            storage.removeValue(forKey: city.lowercased())
            return nil
        }

        return entry.forecast
    }

    func removeForecast(for city: String) {
        lock.lock()
        defer { lock.unlock() }

        storage.removeValue(forKey: city.lowercased())
    }

    func removeAll() {
        lock.lock()
        defer { lock.unlock() }

        storage.removeAll()
    }
}

// MARK: - Entry
private extension ForecastCache {
    final class Entry {
        let forecast: ForecastResponse
        let expiration: Date
        
        init(forecast: ForecastResponse, expiration: Date) {
            self.forecast = forecast
            self.expiration = expiration
        }
        
        var isExpired: Bool {
            Date() >= expiration
        }
    }
}
