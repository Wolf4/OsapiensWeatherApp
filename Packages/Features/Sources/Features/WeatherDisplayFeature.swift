import ComposableArchitecture
import SwiftUI
import WeatherServiceClient
import OpenWeatherMapClient
import OpenMeteoClient
import UIComponents

@Reducer
public struct WeatherDisplayFeature {
    @ObservableState
    public struct State: Equatable {
        public var currentLocation: Location?
        public var weatherData: WeatherData?
        public var isLoading = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case fetchWeather(location: Location, service: WeatherService)
        case weatherResponse(TaskResult<WeatherData>)
        case retryFetch
    }
    
    public init() {}
    
    @Dependency(\.openWeatherMapClient) var openWeatherMapClient
    @Dependency(\.openMeteoClient) var openMeteoClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .fetchWeather(location, service):
                state.currentLocation = location
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    print("🌤️ [Weather] Fetching weather for \(location.name) using \(service)")
                    let result: TaskResult<WeatherData>
                    
                    switch service {
                    case .openWeatherMap:
                        result = await TaskResult { 
                            let weatherData = try await openWeatherMapClient.fetchWeather(for: location)
                            print("🌤️ [Weather] OpenWeatherMap response received for \(location.name)")
                            return weatherData
                        }
                    case .openMeteo:
                        result = await TaskResult { 
                            let weatherData = try await openMeteoClient.fetchWeather(for: location)
                            print("🌤️ [Weather] OpenMeteo response received for \(location.name)")
                            return weatherData
                        }
                    }
                    
                    await send(.weatherResponse(result))
                }
                
            case let .weatherResponse(.success(weatherData)):
                state.isLoading = false
                state.weatherData = weatherData
                state.errorMessage = nil
                return .none
                
            case let .weatherResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .retryFetch:
                guard let location = state.currentLocation else { return .none }
                
                // Determine the service from the last weather data or default to OpenWeatherMap
                let service: WeatherService
                if let weatherData = state.weatherData {
                    service = weatherData.service
                } else {
                    service = .openWeatherMap
                }
                
                return .send(.fetchWeather(location: location, service: service))
            }
        }
    }
}

public struct WeatherDisplayView: View {
    @Bindable var store: StoreOf<WeatherDisplayFeature>
    
    public init(store: StoreOf<WeatherDisplayFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Group {
            if store.isLoading {
                LoadingView(message: "Fetching weather data...")
            } else if let errorMessage = store.errorMessage {
                ErrorView(error: errorMessage) {
                    store.send(.retryFetch)
                }
            } else if let weatherData = store.weatherData,
                      let location = store.currentLocation {
                WeatherContentView(
                    weatherData: weatherData,
                    location: location
                )
            } else {
                EmptyStateView()
            }
        }
        .padding()
    }
}

private struct WeatherContentView: View {
    let weatherData: WeatherData
    let location: Location
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                WeatherCardView(
                    weatherData: weatherData,
                    location: location
                )
                
                // Additional weather information
                VStack(spacing: 16) {
                    Text("Weather Details")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DetailCard(
                            icon: "thermometer",
                            title: "Feels Like",
                            value: "\(Int(round(weatherData.temperature)))°C"
                        )
                        
                        DetailCard(
                            icon: "eye",
                            title: "Visibility",
                            value: "Good"
                        )
                        
                        DetailCard(
                            icon: "sun.max",
                            title: "UV Index",
                            value: "Moderate"
                        )
                        
                        DetailCard(
                            icon: "clock",
                            title: "Updated",
                            value: formattedTime
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: weatherData.lastUpdated)
    }
}

private struct DetailCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("No Weather Data")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Select a location to view weather information")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WeatherDisplayView(
        store: Store(initialState: WeatherDisplayFeature.State()) {
            WeatherDisplayFeature()
        }
    )
} 