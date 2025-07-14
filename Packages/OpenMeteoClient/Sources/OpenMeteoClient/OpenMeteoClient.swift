import Foundation
import WeatherServiceClient

public struct OpenMeteoClient: WeatherServiceClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func fetchWeather(for location: Location) async throws -> WeatherData {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,surface_pressure&timezone=auto"
        
        print("🌤️ [OpenMeteo] Making request to: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidLocation
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherServiceError.networkError("Invalid response type")
            }
            
            print("🌤️ [OpenMeteo] Response status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200:
                print("🌤️ [OpenMeteo] Success response for \(location.name)")
                return try parseWeatherData(from: data, for: location)
            case 400:
                print("🌤️ [OpenMeteo] Invalid location: \(location.name)")
                throw WeatherServiceError.invalidLocation
            case 429:
                print("🌤️ [OpenMeteo] Rate limit exceeded for \(location.name)")
                throw WeatherServiceError.rateLimitExceeded
            default:
                print("🌤️ [OpenMeteo] HTTP error \(httpResponse.statusCode) for \(location.name)")
                throw WeatherServiceError.networkError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as WeatherServiceError {
            throw error
        } catch {
            print("🌤️ [OpenMeteo] Unexpected error: \(error)")
            throw WeatherServiceError.networkError(error.localizedDescription)
        }
    }
    
    private func parseWeatherData(from data: Data, for location: Location) throws -> WeatherData {
        let decoder = JSONDecoder()
        
        // Create a custom date formatter for OpenMeteo's date format (YYYY-MM-DDTHH:mm)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = TimeZone.current
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        do {
            print("🌤️ [OpenMeteo] Parsing response data...")
            let response = try decoder.decode(OpenMeteoResponse.self, from: data)
            let current = response.current
            
            let weatherData = WeatherData(
                temperature: current.temperature2m,
                description: weatherCodeToDescription(current.weatherCode),
                humidity: current.relativeHumidity2m,
                windSpeed: current.windSpeed10m,
                pressure: Int(current.surfacePressure),
                lastUpdated: current.time,
                service: .openMeteo
            )
            
            print("🌤️ [OpenMeteo] Successfully parsed weather data for \(location.name)")
            return weatherData
        } catch {
            print("🌤️ [OpenMeteo] JSON parsing error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🌤️ [OpenMeteo] Raw JSON response: \(jsonString)")
            }
            throw WeatherServiceError.invalidResponse
        }
    }
    
    private func weatherCodeToDescription(_ code: Int) -> String {
        switch code {
        case 0:
            return "Clear sky"
        case 1, 2, 3:
            return "Partly cloudy"
        case 45, 48:
            return "Foggy"
        case 51, 53, 55:
            return "Drizzle"
        case 56, 57:
            return "Freezing drizzle"
        case 61, 63, 65:
            return "Rain"
        case 66, 67:
            return "Freezing rain"
        case 71, 73, 75:
            return "Snow"
        case 77:
            return "Snow grains"
        case 80, 81, 82:
            return "Rain showers"
        case 85, 86:
            return "Snow showers"
        case 95:
            return "Thunderstorm"
        case 96, 99:
            return "Thunderstorm with hail"
        default:
            return "Unknown"
        }
    }
}

// MARK: - Response Models

private struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
}

private struct CurrentWeather: Codable {
    let time: Date
    let temperature2m: Double
    let relativeHumidity2m: Int
    let apparentTemperature: Double
    let precipitation: Double
    let weatherCode: Int
    let windSpeed10m: Double
    let surfacePressure: Double
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case precipitation
        case weatherCode = "weather_code"
        case windSpeed10m = "wind_speed_10m"
        case surfacePressure = "surface_pressure"
    }
} 