//
//  AppCoordinator.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 02.06.2025.
//

import UIKit

/// Главный координатор, отвечающий за инициализацию окна и стартовую навигацию.
@MainActor
final class AppCoordinator: @preconcurrency Coordinator {

    /// Контейнер навигации, используемый для управления стэком экранов.
    let navigationController: UINavigationController

    /// Список дочерних координаторов.
    private var childCoordinators: [Coordinator] = []

    /// Окно приложения.
    private let window: UIWindow?

    /// Инициализирует AppCoordinator с указанным окном.
    /// - Parameter window: UIWindow, в котором происходит отображение UI.
    init(window: UIWindow?) {
        self.window = window
        navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
    }

    /// Запускает координатор и отображает стартовый экран.
    func start() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        showForecast()
    }
    
    func finish() {
        removeAllChildren()
    }
}

// MARK: - Private Methods
private extension AppCoordinator {
    /// Запускает координатор экрана прогноза.
    private func showForecast() {
        let forecastCoordinator = ForecastCoordinator(
            navigationController: navigationController,
            weatherService: makeService()
        )
        addChild(forecastCoordinator)
        forecastCoordinator.start()
    }
    
    private func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    private func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    private func removeAllChildren() {
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
    }
    
    private func makeService() -> WeatherServiceProtocol {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String, !apiKey.isEmpty else {
            fatalError("Missing WEATHER_API_KEY in Info.plist")
        }

        return WeatherService(
            apiKey: apiKey,
            session: URLSession.shared,
            imageCache: ImageCache.shared,
            forecastCache: ForecastCache()
        )
    }
}
