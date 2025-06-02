//
//  ForecastCoordinator.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 02.06.2025.
//

import UIKit

/// Координатор, управляющий экраном прогноза погоды.
@MainActor
final class ForecastCoordinator: @preconcurrency Coordinator {

    /// Контейнер навигации, используемый для отображения экрана прогноза.
    let navigationController: UINavigationController
    
    
    var onFinish: (() -> Void)?

    /// Список дочерних координаторов.
    private var childCoordinators: [Coordinator] = []
    
    /// Сетевой сервис для загрузки прогноза
    private let weatherService: WeatherServiceProtocol

    /// Инициализирует ForecastCoordinator.
    /// - Parameters:
    ///   - navigationController: Контейнер навигации.
    ///   - weatherService: Сервис прогноза погоды.
    init(navigationController: UINavigationController, weatherService: WeatherServiceProtocol) {
        self.navigationController = navigationController
        self.weatherService = weatherService
    }

    /// Запускает отображение экрана прогноза погоды.
    func start() {
        let forecastVM = ForecastViewModel(service: weatherService)
        let forecastVC = ForecastViewController(viewModel: forecastVM)
        navigationController.setViewControllers([forecastVC], animated: false)
    }
    
    func finish() {
        onFinish?()
    }
}
