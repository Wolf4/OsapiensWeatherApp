import Foundation
import WeatherServiceClient

public struct LocationSearchClient {
    private let apiKey: String
    private let session: URLSession
    
    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    public func searchLocations(query: String) async throws -> [Location] {
        guard !apiKey.isEmpty else {
            throw LocationSearchError.apiKeyMissing
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.opencagedata.com/geocode/v1/json?q=\(encodedQuery)&key=\(apiKey)&limit=10"
        
        print("🌍 [LocationSearch] Making request to: \(urlString.replacingOccurrences(of: apiKey, with: "***"))")
        
        guard let url = URL(string: urlString) else {
            throw LocationSearchError.invalidQuery
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LocationSearchError.networkError("Invalid response type")
            }
            
            switch httpResponse.statusCode {
            case 200:
                print("🌍 [LocationSearch] Success response")
                return try parseLocations(from: data)
            case 401:
                print("🌍 [LocationSearch] API key error")
                throw LocationSearchError.apiKeyMissing
            case 429:
                print("🌍 [LocationSearch] Rate limit exceeded")
                throw LocationSearchError.rateLimitExceeded
            default:
                print("🌍 [LocationSearch] HTTP error \(httpResponse.statusCode)")
                throw LocationSearchError.networkError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as LocationSearchError {
            throw error
        } catch {
            throw LocationSearchError.networkError(error.localizedDescription)
        }
    }
    
    private func parseLocations(from data: Data) throws -> [Location] {
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(OpenCageResponse.self, from: data)
            
            return response.results.compactMap { result in
                guard let lat = result.geometry.lat,
                      let lng = result.geometry.lng else {
                    return nil
                }
                
                let components = result.components
                let name = components.city ?? components.town ?? components.village ?? components.county ?? "Unknown"
                let country = components.country
                
                return Location(
                    name: name,
                    latitude: lat,
                    longitude: lng,
                    country: country
                )
            }
        } catch {
            throw LocationSearchError.invalidResponse
        }
    }
}

// MARK: - Error Types

public enum LocationSearchError: Error, Equatable {
    case invalidQuery
    case networkError(String)
    case invalidResponse
    case apiKeyMissing
    case rateLimitExceeded
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidQuery:
            return "Invalid search query"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from geocoding service"
        case .apiKeyMissing:
            return "API key is missing or invalid"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Response Models

private struct OpenCageResponse: Codable {
    let results: [GeocodingResult]
}

private struct GeocodingResult: Codable {
    let components: LocationComponents
    let geometry: Geometry
}

private struct LocationComponents: Codable {
    let city: String?
    let town: String?
    let village: String?
    let county: String?
    let country: String?
}

private struct Geometry: Codable {
    let lat: Double?
    let lng: Double?
} 