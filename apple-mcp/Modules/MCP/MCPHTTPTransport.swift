import Foundation
import MCP
import Network
import Logging

public actor MCPHTTPTransport: Transport {
    public nonisolated let logger: Logger
    private var messageStream: AsyncThrowingStream<Data, any Error>
    private var messageContinuation: AsyncThrowingStream<Data, any Error>.Continuation
    private var connection: NWConnection?

    public init(logger: Logger? = nil) {
        self.logger = logger ?? Logger(label: "com.apple-mcp.mcp-http-transport")
        var continuation: AsyncThrowingStream<Data, any Error>.Continuation!
        self.messageStream = AsyncThrowingStream { continuation = $0 }
        self.messageContinuation = continuation
    }

    public func connect() async throws {
        // For this server-side transport, the connection is managed externally
        // by the HTTPServer. So this method can be a no-op.
    }

    public func disconnect() async {
        messageContinuation.finish()
        connection?.cancel()
        connection = nil
    }

    public func send(_ data: Data) async throws {
        guard let connection = connection else {
            logger.error("No active connection to send data.")
            return
        }

        let response = """
        HTTP/1.1 200 OK
        Content-Type: application/mcp+json
        Content-Length: \(data.count)
        Connection: close

        """
        let responseData = (response + "\r\n").data(using: .utf8)! + data
        connection.send(content: responseData, completion: .contentProcessed { error in
            if let error = error {
                self.logger.error("Error sending MCP response: \(error)")
            }
            connection.cancel()
        })
    }

    public func receive() -> AsyncThrowingStream<Data, any Error> {
        return messageStream
    }

    // This is the method that will be called by the HTTPServer
    public func handle(connection: NWConnection, data: Data) {
        self.connection = connection

        // Extract the MCP payload from the HTTP request body.
        // A simple implementation assumes the body starts after the first "\r\n\r\n".
        if let range = data.range(of: "\r\n\r\n".data(using: .utf8)!) {
            let body = data.subdata(in: range.upperBound..<data.endIndex)
            messageContinuation.yield(body)
        } else {
            logger.error("Could not extract MCP payload from HTTP request.")
        }
    }
}
