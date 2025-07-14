// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OpenWeatherMapClient",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "OpenWeatherMapClient",
            targets: ["OpenWeatherMapClient"]
        ),
    ],
    dependencies: [
        .package(path: "../WeatherServiceClient"),
    ],
    targets: [
        .target(
            name: "OpenWeatherMapClient",
            dependencies: ["WeatherServiceClient"]
        ),
        .testTarget(
            name: "OpenWeatherMapClientTests",
            dependencies: ["OpenWeatherMapClient"]
        ),
    ]
) 