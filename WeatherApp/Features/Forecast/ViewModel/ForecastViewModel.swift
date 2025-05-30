//
//  ForecastViewModel.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation

@MainActor
final class ForecastViewModel: ForecastViewModelProtocol {
    
    // MARK: - Public Properties
    var numberOfItems: Int {
        forecastItems.count
    }
    
    // MARK: - Callbacks
    var onStateChanged: ((ForecastViewState) -> Void)?
    
    // MARK: - Dependencies
    private let service: WeatherServiceProtocol
    
    // MARK: - Private Properties
    private var forecastItems: [ForecastCellViewModel] = []
    
    // Текущая задача загрузки прогноза, чтобы отменять предыдущий запрос
    private var currentFetchTask: Task<[ForecastCellViewModel], Error>?

    // Последний успешный набор элементов прогноза для offline-режима
    private var lastSuccessfulItems: [ForecastCellViewModel] = []
    
    // MARK: - Initializers
    init(service: WeatherServiceProtocol) {
        self.service = service
    }
}

// MARK: - ForecastViewModelProtocol
extension ForecastViewModel {
    func loadForecast(for city: String) async {
        // Отменяем предыдущий запрос, очищаем данные и уведомляем о начале загрузки
        currentFetchTask?.cancel()
        onStateChanged?(.loading)

        // Создаем новую задачу для загрузки прогноза, чтобы её можно было отменить
        let fetchTask = Task { () throws -> [ForecastCellViewModel] in
            let response = try await service.fetchForecast(for: city)
            
            return response.forecast.days.map {
                ForecastCellViewModel(from: $0)
            }
        }
        
        currentFetchTask = fetchTask

        do {
            let items = try await fetchTask.value
            forecastItems = items
            lastSuccessfulItems = items
            onStateChanged?(.loaded)
        } catch is CancellationError {
            // Если запрос был отменен, ничего не делаем
        } catch {
            if !lastSuccessfulItems.isEmpty {
                forecastItems = lastSuccessfulItems
                onStateChanged?(.loaded)
            } else {
                // При ошибке оставляем старые данные и уведомляем об ошибке
                let errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
                onStateChanged?(.failed(errorMessage))
            }
        }
    }
    
    func loadImage(for url: URL) async throws -> Data {
        try await service.fetchImageData(from: url)
    }
    
    func cellViewModel(at index: Int) -> ForecastCellViewModel {
        guard forecastItems.indices.contains(index) else {
            fatalError("Index out of range in ForecastViewModel")
        }
        
        return forecastItems[index]
    }
}
