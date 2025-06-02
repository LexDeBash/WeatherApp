//
//  ForecastViewState.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//


/// Состояние экрана прогноза погоды
enum ForecastViewState: Equatable {
    /// Ожидание первого действия (например, экран пуст)
    case idle

    /// Идёт загрузка прогноза
    case loading

    /// Прогноз успешно загружен
    case loaded

    /// Произошла ошибка при загрузке
    /// - Parameter message: Описание ошибки
    case failed(String)
}
