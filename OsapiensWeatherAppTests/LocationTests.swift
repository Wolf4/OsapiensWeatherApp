//
//  LocationTests.swift
//  OsapiensWeatherAppTests
//
//  Created by Ihar Rubanau on 14/7/25.
//

import XCTest
@testable import WeatherServiceClient

final class LocationTests: XCTestCase {
    
    func testLocationInitialization() {
        let location = Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
        
        XCTAssertEqual(location.name, "San Francisco")
        XCTAssertEqual(location.latitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(location.longitude, -122.4194, accuracy: 0.0001)
        XCTAssertEqual(location.country, "United States")
    }
    
    func testLocationWithoutCountry() {
        let location = Location(
            name: "New York",
            latitude: 40.7128,
            longitude: -74.0060
        )
        
        XCTAssertEqual(location.name, "New York")
        XCTAssertEqual(location.latitude, 40.7128, accuracy: 0.0001)
        XCTAssertEqual(location.longitude, -74.0060, accuracy: 0.0001)
        XCTAssertNil(location.country)
    }
    
    func testLocationEquatable() {
        let location1 = Location(name: "London", latitude: 51.5074, longitude: -0.1278, country: "UK")
        let location2 = Location(name: "London", latitude: 51.5074, longitude: -0.1278, country: "UK")
        let location3 = Location(name: "Paris", latitude: 48.8566, longitude: 2.3522, country: "France")
        
        XCTAssertEqual(location1, location2)
        XCTAssertNotEqual(location1, location3)
    }
    
    func testLocationCodable() {
        let location = Location(name: "Tokyo", latitude: 35.6762, longitude: 139.6503, country: "Japan")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(location)
            let decodedLocation = try decoder.decode(Location.self, from: data)
            XCTAssertEqual(location, decodedLocation)
        } catch {
            XCTFail("Location should be codable: \(error)")
        }
    }
    
    func testLocationWithExtremeCoordinates() {
        let northPole = Location(name: "North Pole", latitude: 90.0, longitude: 0.0)
        let southPole = Location(name: "South Pole", latitude: -90.0, longitude: 0.0)
        let dateLine = Location(name: "Date Line", latitude: 0.0, longitude: 180.0)
        
        XCTAssertEqual(northPole.latitude, 90.0)
        XCTAssertEqual(southPole.latitude, -90.0)
        XCTAssertEqual(dateLine.longitude, 180.0)
    }
} 