import SwiftUI
import ComposableArchitecture
import AppCore

@main
struct WeatherApp: App {
    init() {
        print("🚀 WeatherApp starting up...")
    }
    
    let store = Store(initialState: AppReducer.State()) {
        AppReducer()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
