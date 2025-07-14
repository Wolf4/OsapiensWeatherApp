import XCTest
import ComposableArchitecture
import WeatherServiceClient
import Features
@testable import AppCore

@MainActor
final class AppReducerTests: XCTestCase {
    
    func testLocationSelectedTriggersWeatherFetch() async {
        let location = Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
        
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() }
        )
        
        await store.send(AppReducer.Action.locationInput(LocationInputFeature.Action.locationSelected(location))) {
            $0.locationInput.searchText = ""
            $0.locationInput.searchResults = []
            $0.locationInput.errorMessage = nil
        }
        
        // Skip the weather fetch effect and response since we're testing the location selection flow
        await store.skipInFlightEffects()
        
        // Verify the location was set and weather fetch was triggered
        XCTAssertEqual(store.state.weatherDisplay.currentLocation?.name, "San Francisco")
        XCTAssertTrue(store.state.weatherDisplay.isLoading)
    }
    
    func testServiceSelectionTriggersWeatherRefresh() async {
        let location = Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
        var weatherDisplayState = WeatherDisplayFeature.State()
        weatherDisplayState.currentLocation = location
        weatherDisplayState.weatherData = WeatherData(
            temperature: 22.5,
            description: "Partly cloudy",
            humidity: 65,
            windSpeed: 12.3,
            pressure: 1013,
            lastUpdated: Date(),
            service: WeatherService.openWeatherMap
        )
        weatherDisplayState.isLoading = false
        weatherDisplayState.errorMessage = nil
        
        var state = AppReducer.State()
        state.weatherDisplay = weatherDisplayState
        
        let store = TestStore(
            initialState: state,
            reducer: { AppReducer() }
        )
        
        await store.send(AppReducer.Action.serviceSelection(ServiceSelectionFeature.Action.serviceSelected(WeatherService.openMeteo))) {
            $0.selectedWeatherService = WeatherService.openMeteo
            $0.serviceSelection.selectedService = WeatherService.openMeteo
        }
        
        // Skip the weather fetch effect and response since we're testing the service selection flow
        await store.skipInFlightEffects()
        
        // Verify the service was changed and weather fetch was triggered
        XCTAssertEqual(store.state.selectedWeatherService, WeatherService.openMeteo)
        XCTAssertTrue(store.state.weatherDisplay.isLoading)
    }
    
    func testServiceSelectionWithNoCurrentLocation() async {
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() }
        )
        
        await store.send(AppReducer.Action.serviceSelection(ServiceSelectionFeature.Action.serviceSelected(WeatherService.openMeteo))) {
            $0.selectedWeatherService = WeatherService.openMeteo
            $0.serviceSelection.selectedService = WeatherService.openMeteo
        }
        // No fetchWeather effect should be triggered
    }
    
    func testWeatherServiceChanged() async {
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() }
        )
        
        await store.send(AppReducer.Action.weatherServiceChanged(WeatherService.openMeteo)) {
            $0.selectedWeatherService = WeatherService.openMeteo
        }
        // No effect expected
    }
    
    func testFeatureStateIsolation() async {
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() }
        )
        
        await store.send(AppReducer.Action.locationInput(LocationInputFeature.Action.searchTextChanged("San Francisco"))) {
            $0.locationInput.searchText = "San Francisco"
        }
        
        XCTAssertEqual(store.state.serviceSelection.selectedService, WeatherService.openWeatherMap)
        XCTAssertEqual(store.state.selectedWeatherService, WeatherService.openWeatherMap)
        XCTAssertNil(store.state.weatherDisplay.currentLocation)
    }
    
    func testServiceSelectionStateIsolation() async {
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() }
        )
        
        await store.send(AppReducer.Action.serviceSelection(ServiceSelectionFeature.Action.serviceSelected(WeatherService.openMeteo))) {
            $0.selectedWeatherService = WeatherService.openMeteo
            $0.serviceSelection.selectedService = WeatherService.openMeteo
        }
        
        XCTAssertEqual(store.state.locationInput.searchText, "")
        XCTAssertNil(store.state.weatherDisplay.currentLocation)
    }
    
    func testWeatherDisplayStateIsolation() async {
        let location = Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
        
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() }
        )
        
        await store.send(AppReducer.Action.weatherDisplay(WeatherDisplayFeature.Action.fetchWeather(location: location, service: WeatherService.openWeatherMap))) {
            $0.weatherDisplay.currentLocation = location
            $0.weatherDisplay.isLoading = true
            $0.weatherDisplay.errorMessage = nil
        }
        
        // Skip the weather response since we're testing the fetch trigger
        await store.skipInFlightEffects()
        
        XCTAssertEqual(store.state.locationInput.searchText, "")
        XCTAssertEqual(store.state.serviceSelection.selectedService, WeatherService.openWeatherMap)
        XCTAssertEqual(store.state.selectedWeatherService, WeatherService.openWeatherMap)
    }
    
    func testInitialState() async {
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() }
        )
        
        XCTAssertEqual(store.state.selectedWeatherService, WeatherService.openWeatherMap)
        XCTAssertEqual(store.state.locationInput.searchText, "")
        XCTAssertEqual(store.state.serviceSelection.selectedService, WeatherService.openWeatherMap)
        XCTAssertNil(store.state.weatherDisplay.currentLocation)
        XCTAssertNil(store.state.weatherDisplay.weatherData)
        XCTAssertFalse(store.state.weatherDisplay.isLoading)
        XCTAssertNil(store.state.weatherDisplay.errorMessage)
    }
    
    func testServiceSwitchingFlow() async {
        let location = Location(
            name: "San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            country: "United States"
        )
        
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() }
        )
        
        // Step 1: Select location
        await store.send(AppReducer.Action.locationInput(LocationInputFeature.Action.locationSelected(location))) {
            $0.locationInput.searchText = ""
            $0.locationInput.searchResults = []
            $0.locationInput.errorMessage = nil
        }
        
        // Skip the weather fetch effect
        await store.skipInFlightEffects()
        
        // Step 2: Switch to OpenMeteo
        await store.send(AppReducer.Action.serviceSelection(ServiceSelectionFeature.Action.serviceSelected(WeatherService.openMeteo))) {
            $0.selectedWeatherService = WeatherService.openMeteo
            $0.serviceSelection.selectedService = WeatherService.openMeteo
        }
        
        // Skip the weather fetch effect
        await store.skipInFlightEffects()
        
        // Step 3: Switch back to OpenWeatherMap
        await store.send(AppReducer.Action.serviceSelection(ServiceSelectionFeature.Action.serviceSelected(WeatherService.openWeatherMap))) {
            $0.selectedWeatherService = WeatherService.openWeatherMap
            $0.serviceSelection.selectedService = WeatherService.openWeatherMap
        }
        
        // Skip the weather fetch effect
        await store.skipInFlightEffects()
        
        // Verify final state
        XCTAssertEqual(store.state.selectedWeatherService, WeatherService.openWeatherMap)
        XCTAssertEqual(store.state.serviceSelection.selectedService, WeatherService.openWeatherMap)
        XCTAssertEqual(store.state.weatherDisplay.currentLocation?.name, "San Francisco")
    }
} 