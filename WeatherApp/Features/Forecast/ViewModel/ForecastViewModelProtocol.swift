//
//  ForecastViewModelProtocol.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

/// Протокол модели представления прогноза погоды.
/// Обеспечивает доступ к данным для таблицы и уведомления об изменениях состояния.
@MainActor
protocol ForecastViewModelProtocol: AnyObject {
    
    /// Количество элементов для отображения (1 элемент = 1 день)
    var numberOfItems: Int { get }
    
    /// Колбэк, вызываемый при изменении состояния экрана.
    /// Может использоваться для управления UI в зависимости от состояния загрузки, ошибки и т. д.
    var onStateChanged: ((ForecastViewState) -> Void)? { get set }
    
    /// Загружает прогноз погоды для указанного города.
    /// - Parameter city: Название города (например, "Москва").
    func loadForecast(for city: String) async
    
    /// Загружает изображение по указанному URL (например, иконку прогноза).
    /// - Parameter url: URL изображения.
    /// - Returns: Двоичные данные изображения.
    func loadImage(for url: URL) async throws -> Data

    /// Возвращает модель представления для отображения прогноза в ячейке.
    /// - Parameter index: Индекс дня в массиве прогноза.
    func cellViewModel(at index: Int) -> ForecastCellViewModel
}


