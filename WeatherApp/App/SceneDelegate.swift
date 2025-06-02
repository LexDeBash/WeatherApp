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
            
        window = UIWindow(windowScene: windowScene)
        let appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
    }
}

