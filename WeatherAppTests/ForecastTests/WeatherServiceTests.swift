//
//  WeatherServiceTests.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 31.05.2025.
//

import XCTest
@testable import WeatherApp

final class WeatherServiceTests: XCTestCase {
    
    // MARK: - Private Properties

    /// Общие моки, используемые в тестах
    private var mockCache: MockForecastCache!
    private var mockSession: MockNetworkSession!
    private var service: WeatherService!
    
    /// Проверяет, что при коде 200 и корректном JSON сервис возвращает
    /// ForecastResponse с 5 днями и сохраняет его в кэше (MockForecastCache).
    func test_fetchForecast_success_savesToCacheAndReturnsForecastResponse() async throws {
        // 1. Создаем сервис с параметрами по умолчанию
        let (service, _, _) = makeService()
        
        // 2. Вызываем fetchForecast(for:days:)
        let response = try await service.fetchForecast(for: "moscow", days: 5)

        // 2.1. Проверяем корректность сформированного URL
        guard let requestedURL = mockSession.lastURL else {
            return XCTFail("URL запроса не был сохранён в мок-сессии")
        }
        let components = URLComponents(url: requestedURL, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, "api.weatherapi.com")
        XCTAssertEqual(components?.path, "/v1/forecast.json")
        let queryItems = components?.queryItems ?? []
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "q", value: "moscow")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "days", value: "5")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "key", value: "TEST_API_KEY")))

        
        // 3. Проверяем, что в ответе 5 дней
        XCTAssertEqual(response.forecast.days.count, 5, "Ожидалось 5 дней в ForecastResponse")
        
        // 4. Проверяем данные первого дня
        let firstDay = response.forecast.days[0]
        XCTAssertEqual(firstDay.date, "2025-05-30")
        XCTAssertEqual(firstDay.dayForecast.averageTemperature, 21.5, accuracy: 0.001)
        XCTAssertEqual(firstDay.dayForecast.maxWindSpeed, 12.3, accuracy: 0.001)
        XCTAssertEqual(firstDay.dayForecast.averageHumidity, 55.0, accuracy: 0.001)
        XCTAssertEqual(firstDay.dayForecast.condition.text, "Cloudy")
        XCTAssertEqual(firstDay.dayForecast.condition.icon, "//cdn.weatherapi.com/weather/64x64/day/119.png")
        
        // 5. Проверяем, что ForecastResponse сохранён в кэше под ключом "moscow"
        guard let cached = mockCache.forecast(for: "moscow") else {
            return XCTFail("Ожидалось, что ForecastResponse будет сохранён в кэше под ключом \"moscow\"")
        }
        XCTAssertEqual(cached.forecast.days.count, 5, "В кэше должно быть 5 дней")
        XCTAssertEqual(cached.forecast.days[0].date, "2025-05-30")

        // 6. Проверяем последний (5-й) день: поля не пустые
        let lastDay = response.forecast.days[4]
        XCTAssertFalse(lastDay.date.isEmpty, "Дата пятого дня не должна быть пустой")
        XCTAssertFalse(lastDay.dayForecast.condition.text.isEmpty, "Текст условия пятого дня не должен быть пустым")
        XCTAssertFalse(lastDay.dayForecast.condition.icon.isEmpty, "Иконка пятого дня не должна быть пустой")
    }
    
    /// Если кэш уже содержит данные для данного города, сервис должен их вернуть сразу,
    /// не вызывая сетевой слой (для надёжности прокидываем MockNetworkSession,
    /// который сразу бросает URLError, чтобы убедиться, что к сети не обращаются).
    func test_fetchForecast_withExistingCache_returnsCachedDataWithoutNetworkCall() async throws {
        // Формируем ForecastResponse из JSON и сохраняем его в mockCache
        guard let jsonData = loadJSON(named: "forecast_sample") else {
            return
        }
        
        let preloadedResponse = try JSONDecoder().decode(ForecastResponse.self, from: jsonData)
        
        let (service, _, cache) = makeService(
            jsonName: nil,
            statusCode: 0,
            error: URLError(.notConnectedToInternet)
        )
        
        cache.set(preloadedResponse, for: "berlin")
        
        // Вызываем fetchForecast — он должен вернуть данные из кэша и не бросить ошибку
        let response = try await service.fetchForecast(for: "berlin", days: 3)
        
        // Проверяем, что вернулись именно те же дни, что были в preloadedResponse
        XCTAssertEqual(
            response.forecast.days,
            preloadedResponse.forecast.days,
            "Сервис должен вернуть именно кэшированные данные без сетевого запроса"
        )
    }
    
    /// При сетевой ошибке (Session бросает URLError) сервис не перехватывает её
    /// и просто пробрасывает дальше — поэтому мы ожидаем именно URLError(.notConnectedToInternet).
    func test_fetchForecast_networkError_propagatesURLError() async {
        // 1. MockNetworkSession, который бросает URLError(.notConnectedToInternet)
        let (service, _, cache) = makeService(jsonName: nil, statusCode: 0, error: URLError(.notConnectedToInternet))
        
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
        XCTAssertNil(cache.forecast(for: "rome"), "При сетевой ошибке кэш не должен заполняться")
    }
    
    /// Если сетевой слой вернул HTTP-статус 500 (без кэша) — validateResponse
    /// выбросит WeatherAPIError.httpStatus(500).
    func test_fetchForecast_http500_noCache_throwsHttpStatus() async {
        // 1. Подготавливаем MockNetworkSession, возвращающий статус 500 и пустые данные
        let (service, _, cache) = makeService(jsonName: nil, statusCode: 500, error: nil)
        
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
        XCTAssertNil(cache.forecast(for: "oslo"), "При HTTP 500 кэш не должен заполняться")
    }
    
    /// Если HTTP 500, но в кэше уже лежит ForecastResponse, сервис должен вернуть кэш (а не бросить ошибку).
    func test_fetchForecast_http500_withCache_returnsCachedData() async throws {
        // Предзаполняем mockCache данными из JSON
        guard let jsonData = loadJSON(named: "forecast_sample") else {
            return
        }
        
        let originalResponse = try JSONDecoder().decode(ForecastResponse.self, from: jsonData)
        let (service, _, cache) = makeService(jsonName: nil, statusCode: 500, error: nil)
        cache.set(originalResponse, for: "tokyo")
        
        // Вызываем fetchForecast — ожидаем, что сервис вернёт кэшированные данные
        let response = try await service.fetchForecast(for: "tokyo", days: 3)
        
        // 5. Проверяем, что вернулись именно те же дни, что были в originalResponse
        XCTAssertEqual(
            response.forecast.days,
            originalResponse.forecast.days,
            "При HTTP 500 с заполненным кэшем сервис должен вернуть кэшированные данные"
        )
    }
    
    /// При days вне диапазона 1…10 сервис сразу бросает WeatherAPIError.invalidDayRange и не обращается к сети.
    func test_fetchForecast_invalidDays_throwsInvalidDayRange() async {
        // 1. Подготавливаем MockNetworkSession (он не должен быть вызван, но если вызов произойдёт, бросит ошибку)
        let (service, _, cache) = makeService(
            jsonName: nil,
            statusCode: 0,
            error: URLError(.cannotConnectToHost)
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
        XCTAssertNil(cache.forecast(for: "miami"), "При invalidDayRange кэш не должен заполняться")
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

    /// days = 1 (минимальный валидный) — сервис должен вернуть ответ (не бросает invalidDayRange).
    func test_fetchForecast_daysOne_valid() async throws {
        // Создаём сервис и моки через фабричный метод
        let (service, _, _) = makeService()
        
        // Вызываем fetchForecast с days = 1 — не должно быть ошибки
        do {
            let response = try await service.fetchForecast(for: "paris", days: 1)
            // Проверяем, что вернулся ForecastResponse
            XCTAssertFalse(response.forecast.days.isEmpty, "ForecastResponse не должен быть пустым при days = 1")
        } catch {
            XCTFail("При days = 1 не должно было быть ошибки, получили: \(error)")
        }
    }

    /// days = 10 (максимальный валидный) — сервис должен вернуть ответ (не бросает invalidDayRange).
    func test_fetchForecast_daysTen_valid() async throws {
        let (service, _, _) = makeService()
        
        // Вызываем fetchForecast с days = 10 — не должно быть ошибки
        do {
            let response = try await service.fetchForecast(for: "london", days: 10)
            // Проверяем, что вернулся ForecastResponse
            XCTAssertFalse(response.forecast.days.isEmpty, "ForecastResponse не должен быть пустым при days = 10")
        } catch {
            XCTFail("При days = 10 не должно было быть ошибки, получили: \(error)")
        }
    }

    /// days = 11 (выше максимального) — сервис должен бросить invalidDayRange.
    func test_fetchForecast_daysEleven_throwsInvalidDayRange() async {
        let (service, _, cache) = makeService(jsonName: nil, statusCode: 0, error: URLError(.cannotConnectToHost))
        
        // Вызываем fetchForecast с days = 11 — ожидаем invalidDayRange
        do {
            _ = try await service.fetchForecast(for: "rome", days: 11)
            XCTFail("Ожидалось, что будет брошен WeatherAPIError.invalidDayRange для days = 11")
        } catch let error as WeatherAPIError {
            switch error {
            case .invalidDayRange:
                break // правильно
            default:
                XCTFail("Ожидался WeatherAPIError.invalidDayRange, получили \(error)")
            }
        } catch {
            XCTFail("Ожидался WeatherAPIError.invalidDayRange, но бросилось другое: \(error)")
        }
        
        // Убедимся, что кэш не заполнился
        XCTAssertNil(cache.forecast(for: "rome"), "При invalidDayRange кэш не должен заполняться")
    }
}

// MARK: - Setup
private extension WeatherServiceTests {
    /// Создаёт новые экземпляры MockNetworkSession и MockForecastCache с указанными параметрами,
    /// а также инициализирует WeatherService. Возвращает tuple с сервисом, сессией и кешем.
    ///
    /// - Parameters:
    ///   - jsonName: Имя JSON-файла для загрузки (nil => data = nil).
    ///   - statusCode: HTTP-статус для возвращаемого ответа (по умолчанию 200).
    ///   - error: Ошибка для эмуляции сетевого сбоя (по умолчанию nil).
    /// - Returns: Кортеж (service, session, cache).
    func makeService(
        jsonName: String? = "forecast_sample",
        statusCode: Int = 200,
        error: Error? = nil
    ) -> (service: WeatherService, session: MockNetworkSession, cache: MockForecastCache) {
        let jsonData: Data?
        
        if let jsonName {
            jsonData = loadJSON(named: jsonName)
        } else {
            jsonData = nil
        }
        
        let session = MockNetworkSession(
            data: jsonData,
            statusCode: statusCode,
            headerFields: ["Content-Type": "application/json"],
            error: error
        )
        
        let cache = MockForecastCache()
        
        let service = WeatherService(
            apiKey: "TEST_API_KEY",
            session: session,
            imageCache: MockImageCache(),
            forecastCache: cache
        )
        
        return (service, session, cache)
    }
}

// MARK: — Helpers
private extension WeatherServiceTests {
    /// Загружает JSON-файл из бандла тестового таргета (TestUtils/Resources/forecast_sample.json).
    /// При неудаче вызывает XCTFail и возвращает nil вместо Data.
    func loadJSON(named name: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        
        // 1) Попытка найти URL ресурса
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            XCTFail("Не найден ресурс \(name).json в тестовом бандле")
            return nil
        }
        
        // 2) Попытка считать содержимое файла
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            XCTFail("Не удалось загрузить данные из \(name).json: \(error)")
            return nil
        }
    }
}
