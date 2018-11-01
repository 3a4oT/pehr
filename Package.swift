// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "envStatus",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "3.1.0")),
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/vapor/leaf.git", .upToNextMajor(from: "3.0.2")),
        ],
    targets: [
        .target(name: "App", dependencies: ["Leaf", "FluentSQLite", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

