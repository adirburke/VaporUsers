// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "UserModule",
    platforms: [
       .macOS(.v13)
    ],
    products: [
        .library(name: "Users", targets: ["Users"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.7.2"),
    ],
    targets: [
        .target(
            name: "Users",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "Users"),
            .product(name: "XCTVapor", package: "vapor"),

            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "Fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        ])
    ]
)
