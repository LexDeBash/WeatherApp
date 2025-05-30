//
//  UITableViewCell+ReuseIdentifier.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

import UIKit

extension UITableViewCell {
    /// Уникальный reuseIdentifier, основанный на имени класса
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
