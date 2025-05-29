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
    
    // MARK: - Initializers
    init(service: WeatherServiceProtocol) {
        self.service = service
    }
}

// MARK: - ForecastViewModelProtocol
extension ForecastViewModel {
    func loadForecast(for city: String) async {
        onStateChanged?(.loading)

        do {
            let forecastResponse = try await service.fetchForecast(for: city)
            forecastItems = forecastResponse.forecast.forecastDay.map { ForecastCellViewModel(from: $0) }
            onStateChanged?(.loaded)
        } catch {
            let errorMessage = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
            onStateChanged?(.failed(errorMessage))
        }
    }
    
    func cellViewModel(at index: Int) -> ForecastCellViewModel {
        forecastItems[index]
    }
}
