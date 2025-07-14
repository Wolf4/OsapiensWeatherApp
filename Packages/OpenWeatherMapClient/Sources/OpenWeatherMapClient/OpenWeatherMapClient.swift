import Foundation
import WeatherServiceClient

public struct OpenWeatherMapClient: WeatherServiceClient {
    private let apiKey: String
    private let session: URLSession
    
    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    public func fetchWeather(for location: Location) async throws -> WeatherData {
        guard !apiKey.isEmpty else {
            throw WeatherServiceError.apiKeyMissing
        }
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=metric"
        
        print("🌤️ [OpenWeatherMap] Making request to: \(urlString.replacingOccurrences(of: apiKey, with: "***"))")
        
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidLocation
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherServiceError.networkError("Invalid response type")
            }
            
            switch httpResponse.statusCode {
            case 200:
                print("🌤️ [OpenWeatherMap] Success response for \(location.name)")
                return try parseWeatherData(from: data, for: location)
            case 401:
                print("🌤️ [OpenWeatherMap] API key error for \(location.name)")
                throw WeatherServiceError.apiKeyMissing
            case 429:
                print("🌤️ [OpenWeatherMap] Rate limit exceeded for \(location.name)")
                throw WeatherServiceError.rateLimitExceeded
            case 404:
                print("🌤️ [OpenWeatherMap] Location not found: \(location.name)")
                throw WeatherServiceError.invalidLocation
            default:
                print("🌤️ [OpenWeatherMap] HTTP error \(httpResponse.statusCode) for \(location.name)")
                throw WeatherServiceError.networkError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as WeatherServiceError {
            throw error
        } catch {
            throw WeatherServiceError.networkError(error.localizedDescription)
        }
    }
    
    private func parseWeatherData(from data: Data, for location: Location) throws -> WeatherData {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let response = try decoder.decode(OpenWeatherMapResponse.self, from: data)
            
            return WeatherData(
                temperature: response.main.temp,
                description: response.weather.first?.description ?? "Unknown",
                humidity: response.main.humidity,
                windSpeed: response.wind.speed,
                pressure: response.main.pressure,
                lastUpdated: Date(),
                service: .openWeatherMap
            )
        } catch {
            throw WeatherServiceError.invalidResponse
        }
    }
}

// MARK: - Response Models

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