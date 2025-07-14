import Foundation
import ComposableArchitecture
import OpenWeatherMapClient
import OpenMeteoClient
import LocationSearchClient

extension DependencyValues {
    public var openWeatherMapClient: OpenWeatherMapClient {
        get { self[OpenWeatherMapClientKey.self] }
        set { self[OpenWeatherMapClientKey.self] = newValue }
    }
    
    public var openMeteoClient: OpenMeteoClient {
        get { self[OpenMeteoClientKey.self] }
        set { self[OpenMeteoClientKey.self] = newValue }
    }
    
    public var locationSearchClient: LocationSearchClient {
        get { self[LocationSearchClientKey.self] }
        set { self[LocationSearchClientKey.self] = newValue }
    }
}

private enum OpenWeatherMapClientKey: DependencyKey {
    static let liveValue: OpenWeatherMapClient = {
        let apiKey = Bundle.main.infoDictionary?["OPENWEATHER_API_KEY"] as? String ?? ""
        print("🔑 OpenWeather API Key loaded: \(apiKey.isEmpty ? "EMPTY" : "✓ \(String(apiKey.prefix(8)))...")")
        return OpenWeatherMapClient(apiKey: apiKey)
    }()
    static let testValue = OpenWeatherMapClient(
        apiKey: "test_key",
        session: .shared
    )
}

private enum OpenMeteoClientKey: DependencyKey {
    static let liveValue = OpenMeteoClient()
    static let testValue = OpenMeteoClient()
}

private enum LocationSearchClientKey: DependencyKey {
    static let liveValue: LocationSearchClient = {
        let apiKey = Bundle.main.infoDictionary?["OPENCAGE_API_KEY"] as? String ?? ""
        print("🔑 OpenCage API Key loaded: \(apiKey.isEmpty ? "EMPTY" : "✓ \(String(apiKey.prefix(8)))...")")
        return LocationSearchClient(apiKey: apiKey)
    }()
    static let testValue = LocationSearchClient(
        apiKey: "test_key",
        session: .shared
    )
} 