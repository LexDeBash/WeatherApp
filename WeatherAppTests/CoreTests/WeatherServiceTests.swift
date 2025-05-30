//
//  WeatherServiceTests.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import XCTest
@testable import WeatherApp

final class WeatherServiceTests: XCTestCase {
    
    func testSanity() {
        XCTAssertTrue(true, "Базовый тест проходит")
    }

    func testSuccessfulForecastFetch() async throws {
        // Given
        let jsonData = try XCTUnwrap(loadSampleData(named: "forecast_sample"))
        let mockSession = MockNetworkSession()
        mockSession.mockData = jsonData
        
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let service = WeatherService(
            apiKey: "test",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: MockForecastCache()
        )

        // When
        let result = try await service.fetchForecast(for: "Moscow", days: 5)

        // Then
        XCTAssertEqual(result.forecast.days.count, 5)

        let firstDay = try XCTUnwrap(result.forecast.days.first)
        XCTAssertFalse(firstDay.dayForecast.condition.text.isEmpty)
        XCTAssertFalse(firstDay.dayForecast.condition.icon.isEmpty)
        XCTAssertGreaterThan(firstDay.dayForecast.averageTemperature, -100)
        XCTAssertGreaterThanOrEqual(firstDay.dayForecast.maxWindSpeed, 0)
        XCTAssertGreaterThanOrEqual(firstDay.dayForecast.averageHumidity, 0)
    }

    func testInvalidStatusCodeThrowsError() async {
        // Given
        let mockSession = MockNetworkSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )

        let service = WeatherService(
            apiKey: "test",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: MockForecastCache()
        )

        // When / Then
        do {
            _ = try await service.fetchForecast(for: "Moscow", days: 5)
            XCTFail("Expected error not thrown")
        } catch let WeatherAPIError.httpStatus(code) {
            XCTAssertEqual(code, 429)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUsesCachedForecastIfAvailable() async throws {
        // Given
        let cached = ForecastResponse(forecast: .init(days: [
            ForecastDay(
                date: "2025-05-30",
                dayForecast: .init(
                    averageTemperature: 20,
                    maxWindSpeed: 10,
                    averageHumidity: 50,
                    condition: .init(text: "Sunny", icon: "//cdn.weatherapi.com/sunny.png")
                )
            )
        ]))

        let cache = MockForecastCache()
        cache.set(cached, for: "Moscow")

        let service = WeatherService(
            apiKey: "test",
            session: MockNetworkSession(), // не должен вызываться
            imageCache: MockImageCache(),
            forecastCache: cache
        )

        // When
        let result = try await service.fetchForecast(for: "Moscow", days: 5)

        // Then
        XCTAssertEqual(result.forecast.days.count, 1)
        let firstDay = try XCTUnwrap(result.forecast.days.first)
        XCTAssertEqual(firstDay.date, "2025-05-30")
        XCTAssertEqual(firstDay.dayForecast.condition.text, "Sunny")
    }

    // MARK: - Helpers
    private func loadSampleData(named name: String) throws -> Data {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw XCTSkip("No sample JSON found")
        }
        return try Data(contentsOf: url)
    }
}
