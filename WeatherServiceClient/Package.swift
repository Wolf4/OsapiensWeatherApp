// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WeatherServiceClient",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "WeatherServiceClient",
            targets: ["WeatherServiceClient"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WeatherServiceClient",
            dependencies: []
        ),
        .testTarget(
            name: "WeatherServiceClientTests",
            dependencies: ["WeatherServiceClient"]
        ),
    ]
) 