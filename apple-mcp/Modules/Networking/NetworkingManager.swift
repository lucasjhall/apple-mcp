//
//  NetworkingManager.swift
//  apple-mcp
//

import Foundation

/// Manages all networking services for the application
class NetworkingManager {
    // Singleton instance
    static let shared = NetworkingManager()

    // The HTTP server instance
    private var httpServer: HTTPServer?

    // Default HTTP port
    private let defaultPort: UInt16 = 8080

    // Default bind address
    private let defaultBindAddress = "0.0.0.0"

    // Health check path
    private let healthCheckPath = "/healthz"

    private init() {
        // Private initializer to enforce singleton pattern
    }

    /// Start the HTTP server on the default port
    func startHTTPServer() {
        startHTTPServer(port: defaultPort)
    }

    /// Start the HTTP server on a specific port
    /// - Parameter port: The port number to bind the server to
    func startHTTPServer(port: UInt16) {
        // Stop any existing server first
        stopHTTPServer()

        // Create and start a new server
        httpServer = HTTPServer(port: port)
        httpServer?.start()

        print("NetworkingManager: HTTP server started on port \(port)")
    }

    /// Stop the running HTTP server
    func stopHTTPServer() {
        httpServer?.stop()
        httpServer = nil

        print("NetworkingManager: HTTP server stopped")
    }

    /// Returns whether the HTTP server is currently running
    var isHTTPServerRunning: Bool {
        return httpServer != nil
    }

    /// Returns the URL for the health check endpoint
    var healthCheckURL: URL? {
        return URL(string: "http://localhost:\(defaultPort)\(healthCheckPath)")
    }

    /// Returns the full endpoint string for display purposes
    var healthCheckEndpointString: String {
        return "http://\(defaultBindAddress):\(defaultPort)\(healthCheckPath)"
    }
}
