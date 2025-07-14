//
//  WeatherServiceTests.swift
//  OsapiensWeatherAppTests
//
//  Created by Ihar Rubanau on 14/7/25.
//

import XCTest
@testable import WeatherServiceClient

final class WeatherServiceTests: XCTestCase {
    
    func testWeatherServiceCases() {
        XCTAssertEqual(WeatherService.allCases.count, 2)
        XCTAssertTrue(WeatherService.allCases.contains(.openWeatherMap))
        XCTAssertTrue(WeatherService.allCases.contains(.openMeteo))
    }
    
    func testWeatherServiceDisplayNames() {
        XCTAssertEqual(WeatherService.openWeatherMap.displayName, "OpenWeatherMap")
        XCTAssertEqual(WeatherService.openMeteo.displayName, "OpenMeteo")
    }
    
    func testWeatherServiceAccentColors() {
        XCTAssertEqual(WeatherService.openWeatherMap.accentColor, "blue")
        XCTAssertEqual(WeatherService.openMeteo.accentColor, "green")
    }
    
    func testWeatherServiceEquatable() {
        XCTAssertEqual(WeatherService.openWeatherMap, WeatherService.openWeatherMap)
        XCTAssertNotEqual(WeatherService.openWeatherMap, WeatherService.openMeteo)
    }
    
    func testWeatherServiceCodable() {
        let service = WeatherService.openWeatherMap
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(service)
            let decodedService = try decoder.decode(WeatherService.self, from: data)
            XCTAssertEqual(service, decodedService)
        } catch {
            XCTFail("WeatherService should be codable: \(error)")
        }
    }
    
    func testWeatherServiceEnumeration() {
        let services = WeatherService.allCases
        
        XCTAssertEqual(services.count, 2)
        XCTAssertTrue(services.contains(.openWeatherMap))
        XCTAssertTrue(services.contains(.openMeteo))
        
        // Test that each service has valid properties
        for service in services {
            XCTAssertFalse(service.displayName.isEmpty)
            XCTAssertFalse(service.accentColor.isEmpty)
        }
    }
} 