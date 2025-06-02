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
        
        let viewModel = ForecastCellViewModel(from: forecastDay)
        
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
        
        let viewModel = ForecastCellViewModel(from: forecastDay)
        
        XCTAssertNil(viewModel.iconURL, "iconURL должен быть nil, если icon пустой")
    }
    func test_averageTemperature_roundsUp_whenFractionalPartIsFiveOrGreater() {
        let forecastDay = ForecastDay(
            date: "2025-06-02",
            dayForecast: DayForecast(
                averageTemperature: 17.6,
                maxWindSpeed: 5.0,
                averageHumidity: 40,
                condition: WeatherCondition(
                    text: "Cloudy",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"
                )
            )
        )
        
        let viewModel = ForecastCellViewModel(from: forecastDay)
        
        XCTAssertEqual(viewModel.averageTemperature, "18°C", "Температура должна округляться вверх при дробной части >= 0.5")
    }

    func test_iconURL_nil_whenIconAlreadyHasScheme() {
        let forecastDay = ForecastDay(
            date: "2025-06-02",
            dayForecast: DayForecast(
                averageTemperature: 20.0,
                maxWindSpeed: 5.0,
                averageHumidity: 40,
                condition: WeatherCondition(
                    text: "Rainy",
                    icon: "https://cdn.weatherapi.com/weather/64x64/day/302.png"
                )
            )
        )
        
        let viewModel = ForecastCellViewModel(from: forecastDay)
        
        XCTAssertNil(viewModel.iconURL, "iconURL должен быть nil, если icon уже содержит полную схему URL")
    }
}
