// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OpenMeteoClient",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "OpenMeteoClient",
            targets: ["OpenMeteoClient"]
        ),
    ],
    dependencies: [
        .package(path: "../WeatherServiceClient"),
    ],
    targets: [
        .target(
            name: "OpenMeteoClient",
            dependencies: ["WeatherServiceClient"]
        ),
        .testTarget(
            name: "OpenMeteoClientTests",
            dependencies: ["OpenMeteoClient"]
        ),
    ]
) 