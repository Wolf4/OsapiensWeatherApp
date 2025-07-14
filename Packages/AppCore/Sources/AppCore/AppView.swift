import SwiftUI
import ComposableArchitecture
import Features
import UIComponents

public struct AppView: View {
    @Bindable var store: StoreOf<AppReducer>
    
    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Service Selection at the top
                ServiceSelectionView(
                    store: store.scope(
                        state: \.serviceSelection,
                        action: AppReducer.Action.serviceSelection
                    )
                )
                .padding()
                
                Divider()
                
                // Main content area
                if store.weatherDisplay.currentLocation != nil {
                    WeatherDisplayView(
                        store: store.scope(
                            state: \.weatherDisplay,
                            action: AppReducer.Action.weatherDisplay
                        )
                    )
                } else {
                    LocationInputView(
                        store: store.scope(
                            state: \.locationInput,
                            action: AppReducer.Action.locationInput
                        )
                    )
                }
                
                Spacer()
            }
            .navigationTitle("Weather App")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: store.selectedWeatherService) { _, newService in
            store.send(.weatherServiceChanged(newService))
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppReducer.State()) {
            AppReducer()
        }
    )
} 