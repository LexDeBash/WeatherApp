//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 28.05.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String, !apiKey.isEmpty else {
            fatalError("Missing WEATHER_API_KEY in Info.plist")
        }
        let urlSession = URLSession.shared
        let imageCache: ImageCacheProtocol = ImageCache.shared
        let forecastCache = ForecastCache()
        let weatherService: WeatherServiceProtocol = WeatherService(
            apiKey: apiKey,
            session: urlSession,
            imageCache: imageCache,
            forecastCache: forecastCache
        )
        let forecastVM: ForecastViewModelProtocol = ForecastViewModel(service: weatherService)
        let forecastVC = ForecastViewController(viewModel: forecastVM)
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: forecastVC)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}

