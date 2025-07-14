import Foundation

public enum WeatherService: String, CaseIterable, Equatable, Codable {
    case openWeatherMap = "OpenWeatherMap"
    case openMeteo = "OpenMeteo"
    
    public var displayName: String {
        switch self {
        case .openWeatherMap:
            return "OpenWeatherMap"
        case .openMeteo:
            return "OpenMeteo"
        }
    }
    
    public var accentColor: String {
        switch self {
        case .openWeatherMap:
            return "blue"
        case .openMeteo:
            return "green"
        }
    }
}

public struct Location: Equatable, Codable {
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let country: String?
    
    public init(name: String, latitude: Double, longitude: Double, country: String? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
    }
}

public struct WeatherData: Equatable, Codable {
    public let temperature: Double
    public let description: String
    public let humidity: Int
    public let windSpeed: Double
    public let pressure: Int
    public let lastUpdated: Date
    public let service: WeatherService
    
    public init(
        temperature: Double,
        description: String,
        humidity: Int,
        windSpeed: Double,
        pressure: Int,
        lastUpdated: Date,
        service: WeatherService
    ) {
        self.temperature = temperature
        self.description = description
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.pressure = pressure
        self.lastUpdated = lastUpdated
        self.service = service
    }
}

public enum WeatherServiceError: Error, Equatable {
    case invalidLocation
    case networkError(String)
    case invalidResponse
    case apiKeyMissing
    case rateLimitExceeded
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidLocation:
            return "Invalid location provided"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from weather service"
        case .apiKeyMissing:
            return "API key is missing or invalid"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

public protocol WeatherServiceClient {
    func fetchWeather(for location: Location) async throws -> WeatherData
} 