import SwiftUI
import WeatherServiceClient

public struct WeatherCardView: View {
    public let weatherData: WeatherData
    public let location: Location
    
    public init(weatherData: WeatherData, location: Location) {
        self.weatherData = weatherData
        self.location = location
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Location and service info
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let country = location.country {
                        Text(country)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                ServiceBadge(service: weatherData.service)
            }
            
            // Temperature and description
            VStack(spacing: 8) {
                Text("\(Int(round(weatherData.temperature)))°C")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(accentColor)
                
                Text(weatherData.description.capitalized)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Weather details
            HStack(spacing: 30) {
                WeatherDetailItem(
                    icon: "humidity",
                    title: "Humidity",
                    value: "\(weatherData.humidity)%"
                )
                
                WeatherDetailItem(
                    icon: "wind",
                    title: "Wind",
                    value: "\(Int(round(weatherData.windSpeed))) km/h"
                )
                
                WeatherDetailItem(
                    icon: "gauge",
                    title: "Pressure",
                    value: "\(weatherData.pressure) hPa"
                )
            }
            
            // Last updated
            Text("Last updated: \(formattedDate)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var accentColor: Color {
        switch weatherData.service {
        case .openWeatherMap:
            return .blue
        case .openMeteo:
            return .green
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: weatherData.lastUpdated)
    }
}

private struct ServiceBadge: View {
    let service: WeatherService
    
    var body: some View {
        Text(service.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(accentColor.opacity(0.2))
            )
            .foregroundColor(accentColor)
    }
    
    private var accentColor: Color {
        switch service {
        case .openWeatherMap:
            return .blue
        case .openMeteo:
            return .green
        }
    }
}

private struct WeatherDetailItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    WeatherCardView(
        weatherData: WeatherData(
            temperature: 22.5,
            description: "Partly cloudy",
            humidity: 65,
            windSpeed: 12.3,
            pressure: 1013,
            lastUpdated: Date(),
            service: .openWeatherMap
        ),
        location: Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
    )
    .padding()
} 