//
//  MockNetworkSession.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 30.05.2025.
//


import Foundation
@testable import WeatherApp

final class MockNetworkSession: NetworkSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        return (mockData ?? Data(), mockResponse ?? URLResponse())
    }
}