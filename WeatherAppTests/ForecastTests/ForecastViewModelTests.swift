//
//  ForecastViewModelTests.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 02.06.2025.
//

import XCTest
@testable import WeatherApp

@MainActor
final class ForecastViewModelTests: XCTestCase {
    func test_loadForecast_success_updatesStateAndStoresItems() async {
        // Подготавливаем мок-сервис с успешным результатом
        let service = MockWeatherService()
        service.forecastResult = .success(makeForecastResponse())
        
        // Инициализируем ViewModel
        let viewModel = ForecastViewModel(service: service)
        
        // Перехватываем изменения состояния
        var receivedStates: [ForecastViewState] = []
        viewModel.onStateChanged = { state in
            receivedStates.append(state)
        }
        
        // Вызываем загрузку прогноза
        await viewModel.loadForecast(for: "berlin")
        
        // Проверяем порядок состояний: сначала loading, затем loaded
        XCTAssertEqual(receivedStates.count, 2, "Должно быть 2 состояния: loading и loaded")
        XCTAssertEqual(receivedStates.first, .loading, "Первое состояние должно быть .loading")
        XCTAssertEqual(receivedStates.last, .loaded, "Второе состояние должно быть .loaded")
        
        // Проверяем количество элементов
        XCTAssertEqual(viewModel.numberOfItems, 1, "Ожидался один элемент после успешной загрузки")
        
        // Проверяем содержимое модели ячейки
        let cellVM = viewModel.cellViewModel(at: 0)
        print(cellVM.condition)
        XCTAssertEqual(cellVM.condition, "Cloudy", "Описание погоды должно совпадать")
        XCTAssertEqual(cellVM.averageTemperature, "22°C", "Температура должна быть отформатирована как 22°C")
    }
    
    func test_loadForecast_errorWithoutCache_triggersFailedState() async {
        // Подготавливаем мок-сервис, который возвращает ошибку
        let service = MockWeatherService()
        service.forecastResult = .failure(URLError(.notConnectedToInternet))
        
        // Инициализируем ViewModel
        let viewModel = ForecastViewModel(service: service)
        
        // Перехватываем состояния
        var receivedStates: [ForecastViewState] = []
        viewModel.onStateChanged = { state in
            receivedStates.append(state)
        }
        
        // Вызываем загрузку прогноза
        await viewModel.loadForecast(for: "london")
        
        // Проверяем: сначала .loading, затем .failed
        XCTAssertEqual(receivedStates.count, 2, "Должны быть вызваны два состояния: loading и failed")
        XCTAssertEqual(receivedStates.first, .loading, "Первое состояние должно быть .loading")
        
        // Проверка последнего состояния
        guard case .failed(let message) = receivedStates.last else {
            return XCTFail("Ожидалось состояние .failed с сообщением")
        }
        
        XCTAssertFalse(message.isEmpty, "Сообщение об ошибке не должно быть пустым")
        
        // Убедимся, что forecastItems остался пустым
        XCTAssertEqual(viewModel.numberOfItems, 0, "forecastItems должен быть пуст при ошибке и отсутствии кэша")
    }
    
    func test_loadForecast_errorWithCachedItems_restoresLastSuccessfulAndTriggersLoaded() async {
        // 1. Создаём мок-сервис с изначально успешным результатом
        let service = MockWeatherService()
        let cachedResponse = makeForecastResponse()
        service.forecastResult = .success(cachedResponse)
        
        // 2. Инициализируем ViewModel
        let viewModel = ForecastViewModel(service: service)
        
        // 3. Загружаем данные первый раз — создаём lastSuccessfulItems
        await viewModel.loadForecast(for: "rome")
        
        // 4. Подменяем результат на ошибку (имитируем недоступность сети)
        service.forecastResult = .failure(URLError(.notConnectedToInternet))
        
        // 5. Перехватываем состояния
        var receivedStates: [ForecastViewState] = []
        viewModel.onStateChanged = { state in
            receivedStates.append(state)
        }
        
        // 6. Загружаем повторно (получим ошибку, но должны восстановиться из кэша)
        await viewModel.loadForecast(for: "rome")
        
        // 7. Проверяем последовательность состояний
        XCTAssertEqual(receivedStates.count, 2, "Должны быть вызваны два состояния: loading и loaded")
        XCTAssertEqual(receivedStates.first, .loading, "Первое состояние должно быть .loading")
        XCTAssertEqual(receivedStates.last, .loaded, "Последнее состояние должно быть .loaded (fallback)")

        // 8. Убеждаемся, что forecastItems не очищены
        XCTAssertEqual(viewModel.numberOfItems, 1, "Элементы должны быть восстановлены из lastSuccessfulItems")

        let cell = viewModel.cellViewModel(at: 0)
        XCTAssertEqual(cell.condition, "Cloudy", "Элемент должен соответствовать закэшированному состоянию")
    }
    
    func test_loadImage_error_propagates() async {
        // 1. Создаём ошибку, которую должен вернуть мок
        let expectedError = URLError(.cannotConnectToHost)
        
        // 2. Настраиваем мок-сервис: forecast не нужен, только imageResult
        let service = MockWeatherService()
        service.imageResult = .failure(expectedError)
        
        // 3. Инициализируем ViewModel
        let viewModel = ForecastViewModel(service: service)
        
        // 4. URL, который будем передавать (любой)
        let url = URL(string: "https://example.com/icon.png")!
        
        // 5. Вызываем loadImage и проверяем, что ошибка пробрасывается
        do {
            _ = try await viewModel.loadImage(for: url)
            XCTFail("Ожидалась ошибка URLError(.cannotConnectToHost), но метод завершился успешно")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .cannotConnectToHost, "Ожидался URLError с code .cannotConnectToHost")
        } catch {
            XCTFail("Ожидался URLError, но получена другая ошибка: \(error)")
        }
    }
}

// MARK: - Mocks
private extension ForecastViewModelTests {
    final class MockWeatherService: WeatherServiceProtocol {
        
        var forecastResult: Result<ForecastResponse, Error> = .failure(URLError(.badURL))
        var imageResult: Result<Data, Error> = .failure(URLError(.badURL))
        
        func fetchForecast(for city: String, days: Int) async throws -> ForecastResponse {
            try forecastResult.get()
        }
        
        func fetchImageData(from url: URL) async throws -> Data {
            try imageResult.get()
        }
    }
}

// MARK: - Helpers
private extension ForecastViewModelTests {
    private func makeForecastResponse() -> ForecastResponse {
        let forecastDay = ForecastDay(
            date: "2025-06-02",
            dayForecast: DayForecast(
                averageTemperature: 22.0,
                maxWindSpeed: 10.0,
                averageHumidity: 55,
                condition: WeatherCondition(text: "Cloudy", icon: "//icon.png")
            )
        )
        return ForecastResponse(forecast: Forecast(days: [forecastDay]))
    }
}
