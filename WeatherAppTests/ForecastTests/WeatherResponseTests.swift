//
//  WeatherResponseTests.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 31.05.2025.
//


import XCTest
@testable import WeatherApp

final class WeatherResponseTests: XCTestCase {
    func test_decodingForecastResponse_success() throws {
        // Загружаем пример JSON из ресурсов
        let jsonData = loadJSON(named: "forecast_sample")
        
        // Попытка декодировать JSON в модель ForecastResponse
        let decoder = JSONDecoder()
        let response = try decoder.decode(ForecastResponse.self, from: jsonData)
        
        // Проверяем, что в ответе 5 дней
        XCTAssertEqual(response.forecast.days.count, 5, "Ожидалось 5 элементов в массиве forecastday")
        
        // Проверяем первый день
        let firstDay = response.forecast.days[0]
        XCTAssertEqual(firstDay.date, "2025-05-30", "Неверная дата первого дня")
        XCTAssertEqual(firstDay.dayForecast.averageTemperature, 21.5, accuracy: 0.001, "Неверное avgtemp_c для первого дня")
        XCTAssertEqual(firstDay.dayForecast.maxWindSpeed, 12.3, accuracy: 0.001, "Неверное maxwind_kph для первого дня")
        XCTAssertEqual(firstDay.dayForecast.averageHumidity, 55.0, accuracy: 0.001, "Неверное avghumidity для первого дня")
        XCTAssertEqual(firstDay.dayForecast.condition.text, "Cloudy", "Неверный condition.text для первого дня")
        XCTAssertEqual(firstDay.dayForecast.condition.icon, "//cdn.weatherapi.com/weather/64x64/day/119.png", "Неверный condition.icon для первого дня")
        
        // Проверяем третий день (index 2)
        let thirdDay = response.forecast.days[2]
        XCTAssertEqual(thirdDay.date, "2025-06-01", "Неверная дата третьего дня")
        XCTAssertEqual(thirdDay.dayForecast.averageTemperature, 17.2, accuracy: 0.001, "Неверное avgtemp_c для третьего дня")
        XCTAssertEqual(thirdDay.dayForecast.maxWindSpeed, 10.0, accuracy: 0.001, "Неверное maxwind_kph для третьего дня")
        XCTAssertEqual(thirdDay.dayForecast.averageHumidity, 65.0, accuracy: 0.001, "Неверное avghumidity для третьего дня")
        XCTAssertEqual(thirdDay.dayForecast.condition.text, "Sunny", "Неверный condition.text для третьего дня")
        XCTAssertEqual(thirdDay.dayForecast.condition.icon, "//cdn.weatherapi.com/weather/64x64/day/113.png", "Неверный condition.icon для третьего дня")
        
        // Проверяем последний день
        let lastDay = response.forecast.days[4]
        XCTAssertEqual(lastDay.date, "2025-06-03", "Неверная дата последнего дня")
        XCTAssertEqual(lastDay.dayForecast.averageTemperature, 20.1, accuracy: 0.001, "Неверное avgtemp_c для последнего дня")
        XCTAssertEqual(lastDay.dayForecast.maxWindSpeed, 11.2, accuracy: 0.001, "Неверное maxwind_kph для последнего дня")
        XCTAssertEqual(lastDay.dayForecast.averageHumidity, 58.0, accuracy: 0.001, "Неверное avghumidity для последнего дня")
        XCTAssertEqual(lastDay.dayForecast.condition.text, "Overcast", "Неверный condition.text для последнего дня")
        XCTAssertEqual(lastDay.dayForecast.condition.icon, "//cdn.weatherapi.com/weather/64x64/day/122.png", "Неверный condition.icon для последнего дня")
    }
    
    func test_decodingForecastResponse_missingKeys_throws() {
        // Пример «искажающего» JSON, где отсутствует обязательный ключ внутри "day"
        let invalidJSON = """
        {
          "forecast": {
            "forecastday": [
              {
                "date": "2025-05-30",
                "day": {
                  "maxwind_kph": 12.3,
                  "avghumidity": 55,
                  "condition": {
                    "text": "Cloudy",
                    "icon": "//cdn.weatherapi.com/weather/64x64/day/119.png"
                  }
                }
              }
            ]
          }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(
            try decoder.decode(ForecastResponse.self, from: invalidJSON),
            "Ожидалось, что декодирование бросит ошибку из-за отсутствия ключа avgtemp_c"
        ) { error in
            // Можно проверить тип ошибки, если нужно
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail("Ожидался DecodingError.keyNotFound, получили: \(error)")
            }
            XCTAssertEqual(key.stringValue, "avgtemp_c", "Ожидался пропавший ключ avgtemp_c, получили \(key.stringValue)")
        }
    }
    
    // Helper to load JSON data from TestUtils/Resources
    private func loadJSON(named name: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            fatalError("Не удалось найти \(name).json в тестовом бандле")
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("Не удалось загрузить данные из \(name).json: \(error)")
        }
    }
}
