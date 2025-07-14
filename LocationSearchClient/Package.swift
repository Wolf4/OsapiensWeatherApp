// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LocationSearchClient",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LocationSearchClient",
            targets: ["LocationSearchClient"]
        ),
    ],
    dependencies: [
        .package(path: "../WeatherServiceClient"),
    ],
    targets: [
        .target(
            name: "LocationSearchClient",
            dependencies: ["WeatherServiceClient"]
        ),
        .testTarget(
            name: "LocationSearchClientTests",
            dependencies: ["LocationSearchClient"]
        ),
    ]
) 