import ComposableArchitecture
import SwiftUI
import WeatherServiceClient
import LocationSearchClient
import UIComponents

@Reducer
public struct LocationInputFeature {
    @ObservableState
    public struct State: Equatable {
        public var searchText = ""
        public var searchResults: [Location] = []
        public var isLoading = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case searchTextChanged(String)
        case debouncedSearchTextChanged(String) // NEW
        case searchLocations
        case searchResponse(TaskResult<[Location]>)
        case locationSelected(Location)
        case clearSearch
    }
    
    public init() {}
    
    @Dependency(\.locationSearchClient) var locationSearchClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchTextChanged(text):
                state.searchText = text
                state.errorMessage = nil
                
                if text.isEmpty {
                    state.searchResults = []
                    return .cancel(id: "search")
                }
                // Only search if text is not empty and has at least 2 characters
                guard text.count >= 2 else {
                    return .cancel(id: "search")
                }
                // Use debounce effect
                return .send(.debouncedSearchTextChanged(text))
                    .debounce(id: "search", for: .seconds(2), scheduler: DispatchQueue.main)

            case let .debouncedSearchTextChanged(text):
                // Only search if the debounced text matches the current state
                guard state.searchText == text else { return .none }
                print("🌍 [LocationSearch] Debounce period completed, executing search for: '\(text)'")
                return .send(.searchLocations)
                
            case .searchLocations:
                guard !state.searchText.isEmpty else { return .none }
                
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [searchText = state.searchText] send in
                    print("🌍 [LocationSearch] Searching for: '\(searchText)'")
                    await send(.searchResponse(
                        TaskResult { 
                            let result = try await locationSearchClient.searchLocations(query: searchText)
                            print("🌍 [LocationSearch] Found \(result.count) locations for '\(searchText)'")
                            return result
                        }
                    ))
                }
                
            case let .searchResponse(.success(locations)):
                state.isLoading = false
                state.searchResults = locations
                return .none
                
            case let .searchResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .locationSelected:
                state.searchText = ""
                state.searchResults = []
                state.errorMessage = nil
                return .none
                
            case .clearSearch:
                state.searchText = ""
                state.searchResults = []
                state.errorMessage = nil
                return .none
            }
        }
    }
}

public struct LocationInputView: View {
    @Bindable var store: StoreOf<LocationInputFeature>
    
    public init(store: StoreOf<LocationInputFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "location.magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Find Your Location")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Search for a city, coordinates, or postal code")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Search field
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Enter location...", text: Binding(
                        get: { store.searchText },
                        set: { store.send(.searchTextChanged($0)) }
                    ))
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !store.searchText.isEmpty {
                        Button(action: { store.send(.clearSearch) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // Error message
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            // Search results
            if store.isLoading {
                LoadingView(message: "Searching locations...")
            } else if !store.searchResults.isEmpty {
                List(store.searchResults, id: \.name) { location in
                    LocationRowView(location: location) {
                        store.send(.locationSelected(location))
                    }
                }
                .listStyle(PlainListStyle())
            } else if !store.searchText.isEmpty && !store.isLoading {
                VStack(spacing: 12) {
                    Image(systemName: "location.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No locations found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
    }
}

private struct LocationRowView: View {
    let location: Location
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let country = location.country {
                        Text(country)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LocationInputView(
        store: Store(initialState: LocationInputFeature.State()) {
            LocationInputFeature()
        }
    )
} 