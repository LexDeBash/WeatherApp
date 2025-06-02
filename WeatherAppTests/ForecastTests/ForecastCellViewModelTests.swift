//
//  ForecastCellViewModelTests.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 02.06.2025.
//


import XCTest
@testable import WeatherApp

final class ForecastCellViewModelTests: XCTestCase {
    
    func test_init_setsFormattedValuesCorrectly() {
        // Arrange
        let forecastDay = ForecastDay(
            date: "2025-06-01",
            dayForecast: DayForecast(
                averageTemperature: 17.4,
                maxWindSpeed: 10.6,
                averageHumidity: 63,
                condition: WeatherCondition(
                    text: "Sunny",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
                )
            )
        )
        
        // Act
        let viewModel = ForecastCellViewModel(from: forecastDay)
        
        // Assert
        XCTAssertEqual(
            viewModel.date,
            Date.formattedForecastDate(from: "2025-06-01"),
            "ViewModel должна использовать формат даты из Date.formattedForecastDate(from:)"
        )
        XCTAssertEqual(viewModel.condition, "Sunny", "Текст погодного условия должен совпадать")
        XCTAssertEqual(viewModel.averageTemperature, "17°C", "Температура должна быть округлена и содержать символ °C")
        XCTAssertEqual(viewModel.windSpeed, "Wind speed: 10.6 км/ч", "Скорость ветра должна форматироваться с 1 знаком после запятой")
        XCTAssertEqual(viewModel.humidity, "Humidity: 63%", "Влажность должна быть отформатирована как целое число с символом %")
        XCTAssertEqual(viewModel.iconURL?.absoluteString, "https://cdn.weatherapi.com/weather/64x64/day/113.png", "URL должен быть построен корректно")
    }
    
    func test_iconURL_nil_whenIconIsEmpty() {
        // Arrange
        let forecastDay = ForecastDay(
            date: "2025-06-01",
            dayForecast: DayForecast(
                averageTemperature: 22.0,
                maxWindSpeed: 11.0,
                averageHumidity: 50,
                condition: WeatherCondition(
                    text: "Clear",
                    icon: ""
                )
            )
        )
        
        // Act
        let viewModel = ForecastCellViewModel(from: forecastDay)
        
        // Assert
        XCTAssertNil(viewModel.iconURL, "iconURL должен быть nil, если icon пустой")
    }
}
