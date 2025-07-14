import ComposableArchitecture
import SwiftUI
import WeatherServiceClient

@Reducer
public struct ServiceSelectionFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedService: WeatherService = .openWeatherMap
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case serviceSelected(WeatherService)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .serviceSelected(service):
                state.selectedService = service
                return .none
            }
        }
    }
}

public struct ServiceSelectionView: View {
    @Bindable var store: StoreOf<ServiceSelectionFeature>
    
    public init(store: StoreOf<ServiceSelectionFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Text("Weather Service")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(WeatherService.allCases, id: \.self) { service in
                    ServiceButton(
                        service: service,
                        isSelected: store.selectedService == service
                    ) {
                        store.send(.serviceSelected(service))
                    }
                }
            }
        }
    }
}

private struct ServiceButton: View {
    let service: WeatherService
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: serviceIcon)
                    .font(.subheadline)
                
                Text(service.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? accentColor : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var serviceIcon: String {
        switch service {
        case .openWeatherMap:
            return "cloud.sun.fill"
        case .openMeteo:
            return "leaf.fill"
        }
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

#Preview {
    ServiceSelectionView(
        store: Store(initialState: ServiceSelectionFeature.State()) {
            ServiceSelectionFeature()
        }
    )
    .padding()
} 