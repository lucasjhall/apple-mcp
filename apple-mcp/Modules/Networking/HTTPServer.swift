//
//  HTTPServer.swift
//  apple-mcp
//

import Foundation
import Network

class HTTPServer {
    private var listener: NWListener?
    private let port: UInt16
    private let queue = DispatchQueue(label: "com.apple-mcp.httpserver")

    // Health check path
    private let healthCheckPath = "/healthz"
    // Default bind address
    private let defaultBindAddress = "0.0.0.0"

    init(port: UInt16 = 8080) {
        self.port = port
    }

    func start() {
        do {
            // Create a listener that binds to 0.0.0.0 (all interfaces) on the specified port
            let parameters = NWParameters.tcp
            listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)

            // Set the listener to use all interfaces (0.0.0.0)
            if let listener = listener {
                listener.parameters.requiredLocalEndpoint = nil

                // Set up connection handler
                listener.newConnectionHandler = { [weak self] connection in
                    self?.handleConnection(connection)
                }

                // Start listening
                listener.start(queue: queue)
                print("HTTP Server started on \(defaultBindAddress):\(port)")
            }
        } catch {
            print("Failed to start HTTP server: \(error)")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
        print("HTTP Server stopped")
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 2048) { [weak self] (data, _, isComplete, error) in
            if let data = data, let requestString = String(data: data, encoding: .utf8) {
                print("Received request: \(requestString)")

                // Check if this is a GET request to /healthz
                if let self = self, requestString.starts(with: "GET \(self.healthCheckPath)") {
                    self.sendHealthzResponse(connection)
                } else {
                    self?.sendNotFoundResponse(connection)
                }
            } else if let error = error {
                print("Error receiving data: \(error)")
                connection.cancel()
            } else if isComplete {
                connection.cancel()
            }
        }

        connection.start(queue: queue)
    }

    private func sendHealthzResponse(_ connection: NWConnection) {
        let response = """
        HTTP/1.1 200 OK
        Content-Type: text/plain
        Content-Length: 2
        Connection: close

        OK
        """

        let responseData = response.data(using: .utf8)!
        connection.send(content: responseData, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending response: \(error)")
            }
            connection.cancel()
        })
    }

    private func sendNotFoundResponse(_ connection: NWConnection) {
        let response = """
        HTTP/1.1 404 Not Found
        Content-Type: text/plain
        Content-Length: 9
        Connection: close

        Not Found
        """

        let responseData = response.data(using: .utf8)!
        connection.send(content: responseData, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending response: \(error)")
            }
            connection.cancel()
        })
    }
}
