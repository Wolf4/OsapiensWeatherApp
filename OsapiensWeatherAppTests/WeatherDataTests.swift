//
//  WeatherDataTests.swift
//  OsapiensWeatherAppTests
//
//  Created by Ihar Rubanau on 14/7/25.
//

import XCTest
@testable import WeatherServiceClient

final class WeatherDataTests: XCTestCase {
    
    func testWeatherDataInitialization() {
        let date = Date()
        let weatherData = WeatherData(
            temperature: 22.5,
            description: "Partly cloudy",
            humidity: 65,
            windSpeed: 12.3,
            pressure: 1013,
            lastUpdated: date,
            service: .openWeatherMap
        )
        
        XCTAssertEqual(weatherData.temperature, 22.5, accuracy: 0.1)
        XCTAssertEqual(weatherData.description, "Partly cloudy")
        XCTAssertEqual(weatherData.humidity, 65)
        XCTAssertEqual(weatherData.windSpeed, 12.3, accuracy: 0.1)
        XCTAssertEqual(weatherData.pressure, 1013)
        XCTAssertEqual(weatherData.lastUpdated, date)
        XCTAssertEqual(weatherData.service, .openWeatherMap)
    }
    
    func testWeatherDataEquatable() {
        let date = Date()
        let weatherData1 = WeatherData(
            temperature: 20.0,
            description: "Sunny",
            humidity: 50,
            windSpeed: 10.0,
            pressure: 1015,
            lastUpdated: date,
            service: .openMeteo
        )
        
        let weatherData2 = WeatherData(
            temperature: 20.0,
            description: "Sunny",
            humidity: 50,
            windSpeed: 10.0,
            pressure: 1015,
            lastUpdated: date,
            service: .openMeteo
        )
        
        let weatherData3 = WeatherData(
            temperature: 25.0,
            description: "Cloudy",
            humidity: 60,
            windSpeed: 15.0,
            pressure: 1010,
            lastUpdated: date,
            service: .openWeatherMap
        )
        
        XCTAssertEqual(weatherData1, weatherData2)
        XCTAssertNotEqual(weatherData1, weatherData3)
    }
    
    func testWeatherDataCodable() {
        let date = Date()
        let weatherData = WeatherData(
            temperature: 18.5,
            description: "Light rain",
            humidity: 80,
            windSpeed: 8.5,
            pressure: 1008,
            lastUpdated: date,
            service: .openWeatherMap
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(weatherData)
            let decodedWeatherData = try decoder.decode(WeatherData.self, from: data)
            XCTAssertEqual(weatherData, decodedWeatherData)
        } catch {
            XCTFail("WeatherData should be codable: \(error)")
        }
    }
    
    func testWeatherDataWithExtremeValues() {
        let extremeWeather = WeatherData(
            temperature: -50.0, // Very cold
            description: "Blizzard",
            humidity: 100, // Maximum humidity
            windSpeed: 200.0, // Hurricane force
            pressure: 800, // Very low pressure
            lastUpdated: Date(),
            service: .openWeatherMap
        )
        
        XCTAssertEqual(extremeWeather.temperature, -50.0)
        XCTAssertEqual(extremeWeather.humidity, 100)
        XCTAssertEqual(extremeWeather.windSpeed, 200.0)
        XCTAssertEqual(extremeWeather.pressure, 800)
    }
} 