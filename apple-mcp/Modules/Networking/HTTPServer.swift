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

    var mcpHandler: ((NWConnection, Data) -> Void)?

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
            guard let self = self else { return }

            if let data = data, let requestString = String(data: data, encoding: .utf8) {
                print("Received request: \(requestString)")

                // Simple routing based on path
                let lines = requestString.components(separatedBy: .newlines)
                if let requestLine = lines.first {
                    let components = requestLine.components(separatedBy: " ")
                    if components.count > 1 {
                        let path = components[1]
                        if path == self.healthCheckPath {
                            self.sendHealthzResponse(connection)
                        } else if path == "/mcp" {
                            self.mcpHandler?(connection, data)
                        } else {
                            self.sendNotFoundResponse(connection)
                        }
                    } else {
                        self.sendNotFoundResponse(connection)
                    }
                } else {
                    self.sendNotFoundResponse(connection)
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
