//
//  Coordinator.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 02.06.2025.
//

import UIKit

/// Базовый протокол для всех координаторов, управляющих навигацией.
protocol Coordinator: AnyObject {
    /// Контейнер навигации, используемый для push-переходов.
    var navigationController: UINavigationController { get }
    
    /// Точка входа для запуска координатора.
    func start()
    
    /// Завершает текущего координатора и всех его потомков.
    func finish()
}

extension Coordinator {
    func finish() {}
}
