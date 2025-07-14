import ComposableArchitecture
import WeatherServiceClient
import OpenWeatherMapClient
import OpenMeteoClient
import LocationSearchClient
import Features

@Reducer
public struct AppReducer {
    @ObservableState
    public struct State: Equatable {
        public var locationInput = LocationInputFeature.State()
        public var serviceSelection = ServiceSelectionFeature.State()
        public var weatherDisplay = WeatherDisplayFeature.State()
        public var selectedWeatherService: WeatherService = .openWeatherMap
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case locationInput(LocationInputFeature.Action)
        case serviceSelection(ServiceSelectionFeature.Action)
        case weatherDisplay(WeatherDisplayFeature.Action)
        case weatherServiceChanged(WeatherService)
        case onAppear
    }
    
    public init() {}
    
    @Dependency(\.locationSearchClient) var locationSearchClient
    @Dependency(\.openWeatherMapClient) var openWeatherMapClient
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.locationInput, action: /Action.locationInput) {
            LocationInputFeature()
        }
        
        Scope(state: \.serviceSelection, action: /Action.serviceSelection) {
            ServiceSelectionFeature()
        }
        
        Scope(state: \.weatherDisplay, action: /Action.weatherDisplay) {
            WeatherDisplayFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Force dependency initialization by accessing them
                _ = locationSearchClient
                _ = openWeatherMapClient
                return .none
                
            case let .locationInput(.locationSelected(location)):
                return .send(.weatherDisplay(.fetchWeather(location: location, service: state.selectedWeatherService)))
                
            case let .serviceSelection(.serviceSelected(service)):
                state.selectedWeatherService = service
                if let currentLocation = state.weatherDisplay.currentLocation {
                    return .send(.weatherDisplay(.fetchWeather(location: currentLocation, service: service)))
                }
                return .none
                
            case .weatherServiceChanged(let service):
                state.selectedWeatherService = service
                return .none
                
            case .locationInput, .serviceSelection, .weatherDisplay:
                return .none
            }
        }
    }
} 
