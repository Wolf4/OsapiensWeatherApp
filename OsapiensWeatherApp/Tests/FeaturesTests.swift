import XCTest
import ComposableArchitecture
import WeatherServiceClient
import OpenWeatherMapClient
import OpenMeteoClient
@testable import Features

@MainActor
final class WeatherDisplayFeatureTests: XCTestCase {
    
    func testFetchWeatherSuccess() async {
        let location = Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
        
        let expectedWeatherData = WeatherData(
            temperature: 22.5,
            description: "Partly cloudy",
            humidity: 65,
            windSpeed: 12.3,
            pressure: 1013,
            lastUpdated: Date(),
            service: .openWeatherMap
        )
        
        let store = TestStore(
            initialState: WeatherDisplayFeature.State(),
            reducer: WeatherDisplayFeature()
        ) {
            $0.openWeatherMapClient = OpenWeatherMapClient(
                apiKey: "test_key",
                session: MockURLSession { _ in
                    let response = OpenWeatherMapResponse(
                        weather: [Weather(description: "Partly cloudy")],
                        main: Main(temp: 22.5, humidity: 65, pressure: 1013),
                        wind: Wind(speed: 12.3)
                    )
                    let data = try! JSONEncoder().encode(response)
                    return (data, HTTPURLResponse(url: URL(string: "https://api.openweathermap.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
                }
            )
        }
        
        await store.send(.fetchWeather(location: location, service: .openWeatherMap)) {
            $0.currentLocation = location
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        // Should receive weatherResponse with success
        await store.receive(.weatherResponse(.success(expectedWeatherData))) {
            $0.isLoading = false
            $0.weatherData = expectedWeatherData
            $0.errorMessage = nil
        }
    }
    
    func testFetchWeatherFailure() async {
        let location = Location(
            name: "Invalid Location",
            latitude: 999.0,
            longitude: 999.0,
            country: "Unknown"
        )
        
        let store = TestStore(
            initialState: WeatherDisplayFeature.State(),
            reducer: WeatherDisplayFeature()
        ) {
            $0.openWeatherMapClient = OpenWeatherMapClient(
                apiKey: "invalid_key",
                session: MockURLSession { _ in
                    throw WeatherServiceError.apiKeyMissing
                }
            )
        }
        
        await store.send(.fetchWeather(location: location, service: .openWeatherMap)) {
            $0.currentLocation = location
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        // Should receive weatherResponse with failure
        await store.receive(.weatherResponse(.failure(WeatherServiceError.apiKeyMissing))) {
            $0.isLoading = false
            $0.errorMessage = "API key is missing or invalid"
        }
    }
    
    func testRetryFetch() async {
        let location = Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
        
        let weatherData = WeatherData(
            temperature: 22.5,
            description: "Partly cloudy",
            humidity: 65,
            windSpeed: 12.3,
            pressure: 1013,
            lastUpdated: Date(),
            service: .openWeatherMap
        )
        
        // Use default initializer and mutate properties if needed
        var initialState = WeatherDisplayFeature.State()
        initialState.currentLocation = location
        initialState.weatherData = weatherData
        initialState.isLoading = false
        initialState.errorMessage = "Network error"
        
        let store = TestStore(
            initialState: initialState,
            reducer: WeatherDisplayFeature()
        ) {
            $0.openWeatherMapClient = OpenWeatherMapClient(
                apiKey: "test_key",
                session: MockURLSession { _ in
                    let response = OpenWeatherMapResponse(
                        weather: [Weather(description: "Partly cloudy")],
                        main: Main(temp: 22.5, humidity: 65, pressure: 1013),
                        wind: Wind(speed: 12.3)
                    )
                    let data = try! JSONEncoder().encode(response)
                    return (data, HTTPURLResponse(url: URL(string: "https://api.openweathermap.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
                }
            )
        }
        
        await store.send(.retryFetch) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        // Should receive weatherResponse with success
        await store.receive(.weatherResponse(.success(weatherData))) {
            $0.isLoading = false
            $0.weatherData = weatherData
            $0.errorMessage = nil
        }
    }
    
    func testRetryFetchWithNoLocation() async {
        let store = TestStore(
            initialState: WeatherDisplayFeature.State(),
            reducer: WeatherDisplayFeature()
        )
        
        await store.send(.retryFetch)
        // Should not trigger any effects since there's no current location
        await store.finish()
    }
    
    func testOpenMeteoService() async {
        let location = Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
        
        let expectedWeatherData = WeatherData(
            temperature: 20.0,
            description: "Clear sky",
            humidity: 60,
            windSpeed: 10.0,
            pressure: 1015,
            lastUpdated: Date(),
            service: .openMeteo
        )
        
        let store = TestStore(
            initialState: WeatherDisplayFeature.State(),
            reducer: WeatherDisplayFeature()
        ) {
            $0.openMeteoClient = OpenMeteoClient(session: MockURLSession { _ in
                let response = OpenMeteoResponse(
                    current: OpenMeteoCurrent(
                        temperature_2m: 20.0,
                        relative_humidity_2m: 60,
                        wind_speed_10m: 10.0,
                        surface_pressure: 1015.0,
                        weather_code: 0
                    )
                )
                let data = try! JSONEncoder().encode(response)
                return (data, HTTPURLResponse(url: URL(string: "https://api.open-meteo.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
            })
        }
        
        await store.send(.fetchWeather(location: location, service: .openMeteo)) {
            $0.currentLocation = location
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        // Should receive weatherResponse with success
        await store.receive(.weatherResponse(.success(expectedWeatherData))) {
            $0.isLoading = false
            $0.weatherData = expectedWeatherData
            $0.errorMessage = nil
        }
    }
}

// MARK: - Mock Types

private struct MockURLSession: URLSession {
    let mockDataTask: (URL) throws -> (Data, URLResponse)
    
    init(mockDataTask: @escaping (URL) throws -> (Data, URLResponse)) {
        self.mockDataTask = mockDataTask
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        return try mockDataTask(url)
    }
    
    // Required URLSession methods (simplified for testing)
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try mockDataTask(request.url!)
    }
    
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        return try mockDataTask(url)
    }
    
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        return try mockDataTask(request.url!)
    }
}

// MARK: - Response Models for Testing

private struct OpenWeatherMapResponse: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
}

private struct Weather: Codable {
    let description: String
}

private struct Main: Codable {
    let temp: Double
    let humidity: Int
    let pressure: Int
}

private struct Wind: Codable {
    let speed: Double
}

// MARK: - OpenMeteo Response Models

private struct OpenMeteoResponse: Codable {
    let current: OpenMeteoCurrent
}

private struct OpenMeteoCurrent: Codable {
    let temperature_2m: Double
    let relative_humidity_2m: Int
    let wind_speed_10m: Double
    let surface_pressure: Double
    let weather_code: Int
} 