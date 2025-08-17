import SwiftUI
import MCP
import Logging
import Network

@main
struct apple_mcpApp: App {
    private let mcpManager: MCPManager
    private let mcpTransport: MCPHTTPTransport
    private let networkingManager: NetworkingManager

    init() {
        self.mcpManager = MCPManager()
        self.mcpTransport = MCPHTTPTransport()
        self.networkingManager = NetworkingManager.shared

        // Start the HTTP server first
        self.networkingManager.startHTTPServer()

        // Set the mcpHandler on the http server
        self.networkingManager.setMCPHandler { [weak self] connection, data in
            guard let self = self else { return }
            Task {
                await self.mcpTransport.handle(connection: connection, data: data)
            }
        }

        // Start the MCP server
        Task {
            do {
                try await self.mcpManager.start()
                try await self.mcpManager.server.start(transport: self.mcpTransport)
            } catch {
                print("Failed to start MCP server: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
