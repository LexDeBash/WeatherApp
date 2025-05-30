//
//  WetaherAPIError.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 28.05.2025.
//

import Foundation

/// Ошибки, возникающие при запросах к WeatherAPI
enum WeatherAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(Error)
    case invalidDayRange
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Некорректный URL запроса."
        case .invalidResponse:
            "Сервер вернул некорректный ответ."
        case .httpStatus(let code):
            "Ошибка HTTP: \(code)"
        case .decodingFailed(let error):
            "Ошибка при декодировании ответа: \(error.localizedDescription)"
        case .invalidDayRange:
            "Количество дней должно быть в диапазоне от 1 до 10."
        }
    }
}
