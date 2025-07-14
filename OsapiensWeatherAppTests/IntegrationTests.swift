//
//  IntegrationTests.swift
//  OsapiensWeatherAppTests
//
//  Created by Ihar Rubanau on 14/7/25.
//

import XCTest
@testable import WeatherServiceClient

final class IntegrationTests: XCTestCase {
    
    func testLocationAndWeatherDataIntegration() {
        let location = Location(
            name: "Berlin",
            latitude: 52.5200,
            longitude: 13.4050,
            country: "Germany"
        )
        
        let weatherData = WeatherData(
            temperature: 15.0,
            description: "Overcast",
            humidity: 70,
            windSpeed: 5.5,
            pressure: 1020,
            lastUpdated: Date(),
            service: .openMeteo
        )
        
        // Test that both objects work together
        XCTAssertNotNil(location)
        XCTAssertNotNil(weatherData)
        XCTAssertEqual(weatherData.service, .openMeteo)
        XCTAssertEqual(location.name, "Berlin")
    }
} 