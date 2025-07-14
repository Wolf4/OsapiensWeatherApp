import Foundation
import WeatherKit
import CoreLocation
import WeatherServiceClient

@available(iOS 16.0, *)
public struct WeatherKitClient: WeatherServiceClient {
    private let weatherService: WeatherService
    
    public init(weatherService: WeatherService = .shared) {
        self.weatherService = weatherService
    }
    
    public func fetchWeather(for location: Location) async throws -> WeatherData {
        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        do {
            let weather = try await weatherService.weather(for: coordinate)
            let current = weather.currentWeather
            
            return WeatherData(
                temperature: current.temperature.value,
                description: current.condition.description,
                humidity: Int(current.humidity * 100),
                windSpeed: current.wind.speed.value,
                pressure: Int(current.pressure?.value ?? 1013.25),
                lastUpdated: current.date,
                service: .weatherKit
            )
        } catch {
            throw WeatherServiceError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - Weather Condition Extension

@available(iOS 16.0, *)
extension WeatherCondition {
    var description: String {
        switch self {
        case .clear:
            return "Clear"
        case .cloudy:
            return "Cloudy"
        case .mostlyClear:
            return "Mostly Clear"
        case .mostlyCloudy:
            return "Mostly Cloudy"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .fog:
            return "Fog"
        case .foggy:
            return "Foggy"
        case .haze:
            return "Haze"
        case .windy:
            return "Windy"
        case .blowingDust:
            return "Blowing Dust"
        case .blizzard:
            return "Blizzard"
        case .blowingSnow:
            return "Blowing Snow"
        case .freezingDrizzle:
            return "Freezing Drizzle"
        case .freezingRain:
            return "Freezing Rain"
        case .frigid:
            return "Frigid"
        case .hail:
            return "Hail"
        case .hot:
            return "Hot"
        case .hurricane:
            return "Hurricane"
        case .isolatedThunderstorms:
            return "Isolated Thunderstorms"
        case .mixedSnowAndSleet:
            return "Mixed Snow and Sleet"
        case .mostlyClear:
            return "Mostly Clear"
        case .mostlyCloudy:
            return "Mostly Cloudy"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .rain:
            return "Rain"
        case .scatteredThunderstorms:
            return "Scattered Thunderstorms"
        case .sleet:
            return "Sleet"
        case .snow:
            return "Snow"
        case .strongStorms:
            return "Strong Storms"
        case .sunShowers:
            return "Sun Showers"
        case .thunderstorms:
            return "Thunderstorms"
        case .tropicalStorm:
            return "Tropical Storm"
        case .wintryMix:
            return "Wintry Mix"
        case .breezy:
            return "Breezy"
        case .drizzle:
            return "Drizzle"
        case .heavyRain:
            return "Heavy Rain"
        case .heavySnow:
            return "Heavy Snow"
        case .lightRain:
            return "Light Rain"
        case .lightSnow:
            return "Light Snow"
        case .mostlyClear:
            return "Mostly Clear"
        case .mostlyCloudy:
            return "Mostly Cloudy"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .rain:
            return "Rain"
        case .snow:
            return "Snow"
        case .sunShowers:
            return "Sun Showers"
        case .tropicalStorm:
            return "Tropical Storm"
        case .wintryMix:
            return "Wintry Mix"
        @unknown default:
            return "Unknown"
        }
    }
} 