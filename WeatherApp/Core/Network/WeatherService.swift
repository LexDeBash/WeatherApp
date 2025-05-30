//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 28.05.2025.
//

import Foundation

/// Реализация протокола WeatherServiceProtocol с использованием URLSession и async/await
final class WeatherService {
    // MARK: - Private Properties
    private let apiKey: String
    
    // MARK: - Dependencies
    private let session: URLSession
    private let imageCache: ImageCacheProtocol
    private let forecastCache: ForecastCacheProtocol
    
    // MARK: - Initializers
    init(
        apiKey: String,
        session: URLSession,
        imageCache: ImageCacheProtocol,
        forecastCache: ForecastCacheProtocol
    ) {
        self.apiKey = apiKey
        self.session = session
        self.imageCache = imageCache
        self.forecastCache = forecastCache
    }
}

// MARK: - WeatherServiceProtocol
extension WeatherService: WeatherServiceProtocol {
    func fetchForecast(for city: String, days: Int) async throws -> ForecastResponse {
        if let cachedForecast = forecastCache.forecast(for: city) {
            return cachedForecast
        }
        
        guard (1...10).contains(days) else {
            throw WeatherAPIError.invalidDayRange
        }
        
        let urlComponents = WeatherAPIEndpoint.forecast(city: city, days: days)
        
        guard let url = urlComponents.url(with: apiKey) else {
            throw WeatherAPIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        
        do {
            let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
            forecastCache.set(forecastResponse, for: city)
            return forecastResponse
        } catch {
            throw WeatherAPIError.decodingFailed(error)
        }
    }
    
    func fetchImageData(from url: URL) async throws -> Data {
        if let cachedImageData = imageCache.imageData(for: url) {
            return cachedImageData
        }
        
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        
        imageCache.storeImageData(data, for: url)
        
        return data
    }
}

// MARK: - Private Methods
extension WeatherService {
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAPIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherAPIError.httpStatus(httpResponse.statusCode)
        }
    }
}
