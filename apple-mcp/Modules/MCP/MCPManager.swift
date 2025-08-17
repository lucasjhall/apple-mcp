import Foundation
import MCP

class MCPManager {
    let server: Server
    private let eventManager: EventManager

    init() {
        self.server = Server(
            name: "apple-mcp-server",
            version: "1.0.0",
            capabilities: .init(
                tools: .init(listChanged: false)
            )
        )
        self.eventManager = EventManager()
    }

    private func registerToolHandlers() async {
        await server.withMethodHandler(ListTools.self) { _ in
            let tools = [
                Tool(
                    name: "get_events_today",
                    description: "Get a list of today's calendar events."
                )
            ]
            return .init(tools: tools)
        }

        await server.withMethodHandler(CallTool.self) { params in
            switch params.name {
            case "get_events_today":
                let today = Date()
                let startOfDay = Calendar.current.startOfDay(for: today)
                let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

                do {
                    let events = try await self.getEvents(from: startOfDay, to: endOfDay)
                    let eventData = try JSONEncoder().encode(events)
                    let eventJSON = String(data: eventData, encoding: .utf8) ?? "[]"
                    return .init(content: [.text(eventJSON)], isError: false)
                } catch {
                    return .init(content: [.text("Error getting events: \(error.localizedDescription)")], isError: true)
                }
            default:
                return .init(content: [.text("Unknown tool: \(params.name)")], isError: true)
            }
        }
    }

    private func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event] {
        return try await withCheckedThrowingContinuation { continuation in
            eventManager.getEvents(from: startDate, to: endDate) { events, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: events ?? [])
                }
            }
        }
    }

    func start() async throws {
        await registerToolHandlers()
        // The server will be started with a transport in a later step.
    }
}
