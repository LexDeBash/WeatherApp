//
//  WeatherServiceTests.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 31.05.2025.
//

import XCTest
@testable import WeatherApp

final class WeatherServiceTests: XCTestCase {
    
    /// Проверяет, что при коде 200 и корректном JSON сервис возвращает
    /// ForecastResponse с 5 днями и сохраняет его в кэше (MockForecastCache).
    func test_fetchForecast_success_savesToCacheAndReturnsForecastResponse() async throws {
        // 1. Читаем пример JSON и подготавливаем MockNetworkSession (200 + корректный JSON)
        let jsonData = loadJSON(named: "forecast_sample")
        let mockSession = MockNetworkSession(
            data: jsonData,
            statusCode: 200,
            headerFields: ["Content-Type": "application/json"],
            error: nil
        )
        
        // 2. Создаём пустой MockForecastCache
        let mockCache = MockForecastCache()
        
        // 3. Инициализируем сервис WeatherService со всеми зависимостями
        let service = WeatherService(
            apiKey: "TEST_API_KEY",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: mockCache
        )
        
        // 4. Вызываем fetchForecast(for:days:)
        let response = try await service.fetchForecast(for: "moscow", days: 5)
        
        // 5. Проверяем, что в ответе 5 дней
        XCTAssertEqual(response.forecast.days.count, 5, "Ожидалось 5 дней в ForecastResponse")
        
        // 6. Проверяем данные первого дня
        let firstDay = response.forecast.days[0]
        XCTAssertEqual(firstDay.date, "2025-05-30")
        XCTAssertEqual(firstDay.dayForecast.averageTemperature, 21.5, accuracy: 0.001)
        XCTAssertEqual(firstDay.dayForecast.maxWindSpeed, 12.3, accuracy: 0.001)
        XCTAssertEqual(firstDay.dayForecast.averageHumidity, 55.0, accuracy: 0.001)
        XCTAssertEqual(firstDay.dayForecast.condition.text, "Cloudy")
        XCTAssertEqual(firstDay.dayForecast.condition.icon, "//cdn.weatherapi.com/weather/64x64/day/119.png")
        
        // 7. Проверяем, что ForecastResponse сохранён в кэше под ключом "moscow"
        guard let cached = mockCache.forecast(for: "moscow") else {
            return XCTFail("Ожидалось, что ForecastResponse будет сохранён в кэше под ключом \"moscow\"")
        }
        XCTAssertEqual(cached.forecast.days.count, 5, "В кэше должно быть 5 дней")
        XCTAssertEqual(cached.forecast.days[0].date, "2025-05-30")
    }
    
    /// Если кэш уже содержит данные для данного города, сервис должен их вернуть сразу,
    /// не вызывая сетевой слой (для надёжности прокидываем MockNetworkSession,
    /// который сразу бросает URLError, чтобы убедиться, что к сети не обращаются).
    func test_fetchForecast_withExistingCache_returnsCachedDataWithoutNetworkCall() async throws {
        // 1. Формируем ForecastResponse из JSON и сохраняем его в mockCache
        let jsonData = loadJSON(named: "forecast_sample")
        let decoder = JSONDecoder()
        let preloadedResponse = try decoder.decode(ForecastResponse.self, from: jsonData)
        
        let mockCache = MockForecastCache()
        mockCache.set(preloadedResponse, for: "berlin")
        
        // 2. Подготавливаем MockNetworkSession, который бросает URLError, если будет вызван
        let mockSession = MockNetworkSession(
            data: nil,
            statusCode: 0,
            headerFields: nil,
            error: URLError(.notConnectedToInternet)
        )
        
        // 3. Инициализируем сервис с этим mockCache и «плохим» session
        let service = WeatherService(
            apiKey: "TEST_API_KEY",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: mockCache
        )
        
        // 4. Вызываем fetchForecast — он должен вернуть данные из кэша и не бросить ошибку
        let response = try await service.fetchForecast(for: "berlin", days: 3)
        
        // 5. Проверяем, что вернулись именно те же дни, что были в preloadedResponse
        XCTAssertEqual(response.forecast.days, preloadedResponse.forecast.days,
                       "Сервис должен вернуть именно кэшированные данные без сетевого запроса")
    }
    
    /// При сетевой ошибке (Session бросает URLError) сервис не перехватывает её
    /// и просто пробрасывает дальше — поэтому мы ожидаем именно URLError(.notConnectedToInternet).
    func test_fetchForecast_networkError_propagatesURLError() async {
        // 1. MockNetworkSession, который бросает URLError(.notConnectedToInternet)
        let networkError = URLError(.notConnectedToInternet)
        let mockSession = MockNetworkSession(
            data: nil,
            statusCode: 0,
            headerFields: nil,
            error: networkError
        )
        let mockCache = MockForecastCache() // пустой кэш
        
        let service = WeatherService(
            apiKey: "TEST_API_KEY",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: mockCache
        )
        
        // 2. Вызываем fetchForecast — ожидаем, что бросится URLError(.notConnectedToInternet)
        do {
            _ = try await service.fetchForecast(for: "rome", days: 4)
            XCTFail("Ожидалось, что будет проброшен URLError(.notConnectedToInternet)")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet, "Ожидался URLError.notConnectedToInternet")
        } catch {
            XCTFail("Ожидался URLError, но бросилось другое: \(error)")
        }
        
        // 3. Убедимся, что кэш остался пуст
        XCTAssertNil(mockCache.forecast(for: "rome"), "При сетевой ошибке кэш не должен заполняться")
    }
    
    /// Если сетевой слой вернул HTTP-статус 500 (без кэша) — validateResponse
    /// выбросит WeatherAPIError.httpStatus(500).
    func test_fetchForecast_http500_noCache_throwsHttpStatus() async {
        // 1. Подготавливаем MockNetworkSession, возвращающий статус 500 и пустые данные
        let mockSession = MockNetworkSession(
            data: nil,
            statusCode: 500,
            headerFields: ["Content-Type": "application/json"],
            error: nil
        )
        let mockCache = MockForecastCache() // пустой
        
        let service = WeatherService(
            apiKey: "TEST_API_KEY",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: mockCache
        )
        
        // 2. Вызываем fetchForecast — ожидаем WeatherAPIError.httpStatus(500)
        do {
            _ = try await service.fetchForecast(for: "oslo", days: 2)
            XCTFail("Ожидалось, что будет брошен WeatherAPIError.httpStatus(500)")
        } catch let error as WeatherAPIError {
            switch error {
            case .httpStatus(let code):
                XCTAssertEqual(code, 500, "Ожидался код 500")
            default:
                XCTFail("Ожидался WeatherAPIError.httpStatus(500), получили \(error)")
            }
        } catch {
            XCTFail("Ожидался WeatherAPIError.httpStatus, но бросилось другое: \(error)")
        }
        
        // 3. Убедимся, что кэш пуст
        XCTAssertNil(mockCache.forecast(for: "oslo"), "При HTTP 500 кэш не должен заполняться")
    }
    
    /// Если HTTP 500, но в кэше уже лежит ForecastResponse, сервис должен вернуть кэш (а не бросить ошибку).
    func test_fetchForecast_http500_withCache_returnsCachedData() async throws {
        // 1. Предзаполняем mockCache данными из JSON
        let jsonData = loadJSON(named: "forecast_sample")
        let decoder = JSONDecoder()
        let originalResponse = try decoder.decode(ForecastResponse.self, from: jsonData)
        
        let mockCache = MockForecastCache()
        mockCache.set(originalResponse, for: "tokyo")
        
        // 2. MockNetworkSession возвращает 500 без ошибки
        let mockSession = MockNetworkSession(
            data: nil,
            statusCode: 500,
            headerFields: ["Content-Type": "application/json"],
            error: nil
        )
        
        // 3. Инициализируем сервис с тем же mockCache
        let service = WeatherService(
            apiKey: "TEST_API_KEY",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: mockCache
        )
        
        // 4. Вызываем fetchForecast — ожидаем, что сервис вернёт кэшированные данные
        let response = try await service.fetchForecast(for: "tokyo", days: 3)
        
        // 5. Проверяем, что вернулись именно те же дни, что были в originalResponse
        XCTAssertEqual(response.forecast.days, originalResponse.forecast.days,
                       "При HTTP 500 с заполненным кэшем сервис должен вернуть кэшированные данные")
    }
    
    /// При days вне диапазона 1…10 сервис сразу бросает WeatherAPIError.invalidDayRange и не обращается к сети.
    func test_fetchForecast_invalidDays_throwsInvalidDayRange() async {
        // 1. Подготавливаем MockNetworkSession (он не должен быть вызван, но если вызов произойдёт, бросит ошибку)
        let mockSession = MockNetworkSession(
            data: nil,
            statusCode: 0,
            headerFields: nil,
            error: URLError(.cannotConnectToHost)
        )
        let mockCache = MockForecastCache()
        
        let service = WeatherService(
            apiKey: "TEST_API_KEY",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: mockCache
        )
        
        // 2. Вызываем fetchForecast с days = 0
        do {
            _ = try await service.fetchForecast(for: "miami", days: 0)
            XCTFail("Ожидалось, что будет брошен WeatherAPIError.invalidDayRange")
        } catch let error as WeatherAPIError {
            switch error {
            case .invalidDayRange:
                break // всё верно
            default:
                XCTFail("Ожидался WeatherAPIError.invalidDayRange, получили \(error)")
            }
        } catch {
            XCTFail("Ожидался WeatherAPIError.invalidDayRange, но бросилось другое: \(error)")
        }
        
        // 3. Убедимся, что кэш не заполнился
        XCTAssertNil(mockCache.forecast(for: "miami"), "При invalidDayRange кэш не должен заполняться")
    }
    
    /// Если HTTP 200, но JSON не соответствует модели (ForecastResponse), сервис выбросит WeatherAPIError.decodingFailed.
    func test_fetchForecast_invalidJSON_throwsDecodingFailed() async {
        // 1. Готовим «сломанный» JSON (например, нет ключа "forecast")
        let invalidJSON = """
        {
          "wrongKey": {
            "forecastday": []
          }
        }
        """.data(using: .utf8)!
        
        let mockSession = MockNetworkSession(
            data: invalidJSON,
            statusCode: 200,
            headerFields: ["Content-Type": "application/json"],
            error: nil
        )
        let mockCache = MockForecastCache()
        
        let service = WeatherService(
            apiKey: "TEST_API_KEY",
            session: mockSession,
            imageCache: MockImageCache(),
            forecastCache: mockCache
        )
        
        // 2. Вызываем fetchForecast — ожидаем, что появится WeatherAPIError.decodingFailed
        do {
            _ = try await service.fetchForecast(for: "tokyo", days: 5)
            XCTFail("Ожидалось, что будет брошен WeatherAPIError.decodingFailed")
        } catch let error as WeatherAPIError {
            switch error {
            case .decodingFailed:
                break // верно
            default:
                XCTFail("Ожидался WeatherAPIError.decodingFailed, получили \(error)")
            }
        } catch {
            XCTFail("Ожидался WeatherAPIError.decodingFailed, но бросилось другое: \(error)")
        }
        
        // 3. Убедимся, что кэш остался пуст
        XCTAssertNil(mockCache.forecast(for: "tokyo"), "При decodingFailed кэш не должен заполняться")
    }
}

// MARK: — Helpers
extension WeatherServiceTests {
    /// Загружает JSON-файл из бандла тестового таргета (TestUtils/Resources/forecast_sample.json).
    private func loadJSON(named name: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            fatalError("Не удалось найти \(name).json в тестовом бандле")
        }
        return try! Data(contentsOf: url)
    }
}
