// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Features",
            targets: ["Features"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(path: "../WeatherServiceClient"),
        .package(path: "../OpenWeatherMapClient"),
        .package(path: "../OpenMeteoClient"),
        .package(path: "../LocationSearchClient"),
        .package(path: "../UIComponents"),
    ],
    targets: [
        .target(
            name: "Features",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "WeatherServiceClient",
                "OpenWeatherMapClient",
                "OpenMeteoClient",
                "LocationSearchClient",
                "UIComponents",
            ]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: [
                "Features",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
) 