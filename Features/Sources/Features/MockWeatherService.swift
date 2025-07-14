import Foundation
import WeatherServiceClient

public struct MockWeatherService: WeatherServiceClient {
    private let shouldSucceed: Bool
    private let mockData: WeatherData?
    private let mockError: WeatherServiceError?
    
    public init(
        shouldSucceed: Bool = true,
        mockData: WeatherData? = nil,
        mockError: WeatherServiceError? = nil
    ) {
        self.shouldSucceed = shouldSucceed
        self.mockData = mockData
        self.mockError = mockError
    }
    
    public func fetchWeather(for location: Location) async throws -> WeatherData {
        if shouldSucceed {
            if let mockData = mockData {
                return mockData
            } else {
                return WeatherData(
                    temperature: 22.5,
                    description: "Partly cloudy",
                    humidity: 65,
                    windSpeed: 12.3,
                    pressure: 1013,
                    lastUpdated: Date(),
                    service: .openWeatherMap
                )
            }
        } else {
            throw mockError ?? WeatherServiceError.networkError("Mock error")
        }
    }
}

// MARK: - Convenience Initializers

extension MockWeatherService {
    public static func success(data: WeatherData? = nil) -> MockWeatherService {
        MockWeatherService(shouldSucceed: true, mockData: data)
    }
    
    public static func failure(error: WeatherServiceError) -> MockWeatherService {
        MockWeatherService(shouldSucceed: false, mockError: error)
    }
    
    public static func networkError() -> MockWeatherService {
        MockWeatherService(shouldSucceed: false, mockError: .networkError("Network error"))
    }
    
    public static func apiKeyMissing() -> MockWeatherService {
        MockWeatherService(shouldSucceed: false, mockError: .apiKeyMissing)
    }
} 