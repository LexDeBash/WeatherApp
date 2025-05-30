//
//  UIView+AutoLayout.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import UIKit

extension UIView {
    /// Возвращает представление с отключенным флагом Autoresizing Mask.
    func preparedForAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
