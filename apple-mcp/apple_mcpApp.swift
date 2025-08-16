//
//  apple_mcpApp.swift
//  apple-mcp
//
//  Created by lucas on 8/16/25.
//

import SwiftUI

@main
struct apple_mcpApp: App {
    // State to manage the app lifecycle
    @Environment(\.scenePhase) private var scenePhase

    // Initialize the Networking Manager to handle HTTP server
    private let networkingManager = NetworkingManager.shared
    private let remindersManager = RemindersManager.shared

    var body: some Scene {
        WindowGroup {
            // Use our ContentView which includes the WelcomeView and server status
            ContentView()
                .onAppear {
                    // Start the HTTP server when the view appears
                    startHTTPServer()

                    // Request access to reminders
                    remindersManager.requestAccess { granted, error in
                        if granted {
                            print("Reminders access granted.")
                        } else {
                            print("Reminders access denied.")
                        }
                    }
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // App became active - ensure server is running
                startHTTPServer()
            case .background:
                // App went to background - consider if you want to stop the server
                // For a health check server, we'll keep it running even in background
                break
            case .inactive:
                // App is inactive but might become active again soon
                break
            @unknown default:
                break
            }
        }
    }

    // Helper method to start the HTTP server
    private func startHTTPServer() {
        if !networkingManager.isHTTPServerRunning {
            networkingManager.startHTTPServer()
        }
    }
}
