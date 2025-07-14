//
//  WeatherServiceErrorTests.swift
//  OsapiensWeatherAppTests
//
//  Created by Ihar Rubanau on 14/7/25.
//

import XCTest
@testable import WeatherServiceClient

final class WeatherServiceErrorTests: XCTestCase {
    
    func testWeatherServiceErrorCases() {
        let errors: [WeatherServiceError] = [
            .invalidLocation,
            .networkError("Connection failed"),
            .invalidResponse,
            .apiKeyMissing,
            .rateLimitExceeded,
            .unknown("Something went wrong")
        ]
        
        XCTAssertEqual(errors.count, 6)
    }
    
    func testWeatherServiceErrorLocalizedDescriptions() {
        XCTAssertEqual(WeatherServiceError.invalidLocation.localizedDescription, "Invalid location provided")
        XCTAssertEqual(WeatherServiceError.networkError("Timeout").localizedDescription, "Network error: Timeout")
        XCTAssertEqual(WeatherServiceError.invalidResponse.localizedDescription, "Invalid response from weather service")
        XCTAssertEqual(WeatherServiceError.apiKeyMissing.localizedDescription, "API key is missing or invalid")
        XCTAssertEqual(WeatherServiceError.rateLimitExceeded.localizedDescription, "Rate limit exceeded")
        XCTAssertEqual(WeatherServiceError.unknown("Test error").localizedDescription, "Unknown error: Test error")
    }
    
    func testWeatherServiceErrorEquatable() {
        XCTAssertEqual(WeatherServiceError.invalidLocation, WeatherServiceError.invalidLocation)
        XCTAssertEqual(WeatherServiceError.networkError("Error"), WeatherServiceError.networkError("Error"))
        XCTAssertNotEqual(WeatherServiceError.networkError("Error1"), WeatherServiceError.networkError("Error2"))
        XCTAssertNotEqual(WeatherServiceError.invalidLocation, WeatherServiceError.apiKeyMissing)
    }
} 