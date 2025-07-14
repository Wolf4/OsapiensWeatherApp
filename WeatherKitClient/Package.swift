// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WeatherKitClient",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "WeatherKitClient",
            targets: ["WeatherKitClient"]
        ),
    ],
    dependencies: [
        .package(path: "../WeatherServiceClient"),
    ],
    targets: [
        .target(
            name: "WeatherKitClient",
            dependencies: ["WeatherServiceClient"]
        ),
        .testTarget(
            name: "WeatherKitClientTests",
            dependencies: ["WeatherKitClient"]
        ),
    ]
) 