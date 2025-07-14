// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AppCore",
            targets: ["AppCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(path: "../WeatherServiceClient"),
        .package(path: "../OpenWeatherMapClient"),
        .package(path: "../OpenMeteoClient"),
        .package(path: "../LocationSearchClient"),
        .package(path: "../UIComponents"),
        .package(path: "../Features"),
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "WeatherServiceClient",
                "OpenWeatherMapClient",
                "OpenMeteoClient",
                "LocationSearchClient",
                "UIComponents",
                "Features",
            ]
        ),
        .testTarget(
            name: "AppCoreTests",
            dependencies: [
                "AppCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
) 