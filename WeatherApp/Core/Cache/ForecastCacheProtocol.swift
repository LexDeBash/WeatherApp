//
//  ForecastCacheProtocol.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//

/// Протокол для кэширования объектов с ограниченным сроком жизни.
protocol ForecastCacheProtocol {
    /// Сохраняет значение по ключу.
    func set(_ forecast: ForecastResponse, for city: String)
        
    /// Возвращает значение по ключу, если оно есть и не истекло.
    func forecast(for city: String) -> ForecastResponse?
    
    /// Удаляет значение по ключу.
    func removeForecast(for city: String)
    
    /// Удаляет все значения из кэша.
    func removeAll()
}
