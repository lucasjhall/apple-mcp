// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "apple-mcp",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.10.0")
    ],
    targets: [
        .target(
            name: "apple-mcp",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ],
            path: "apple-mcp",
            exclude: ["Modules/MCP/.gitkeep", "Modules/Alarms/.gitkeep", "Modules/Notes/.gitkeep", "Modules/Reminders/.gitkeep"],
            sources: [
                "ContentView.swift",
                "Modules/Calendar/EventStoreManager.swift",
                "Modules/Calendar/CalendarModels.swift",
                "Modules/Calendar/CalendarManager.swift",
                "Modules/Calendar/EventManager.swift",
                "Modules/Networking/NetworkingManager.swift",
                "Modules/Networking/HTTPServer.swift",
                "Modules/UI/WelcomeView.swift",
                "apple_mcpApp.swift"
            ]
        )
    ]
)
