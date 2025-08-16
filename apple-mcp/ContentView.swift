//
//  ContentView.swift
//  apple-mcp
//
//  Created by lucas on 8/16/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    // State to track if the server is running
    @State private var isServerRunning = false
    @State private var serverStatusMessage = "Server Status: Not started"

    // Timer to periodically check server status
    private let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()

    // Reference to the networking manager
    private let networkingManager = NetworkingManager.shared

    var body: some View {
        VStack(spacing: 30) {
            // Welcome header
            WelcomeView()

            Divider()

            // Server status section
            VStack(alignment: .leading, spacing: 10) {
                Text("HTTP Server Information")
                    .font(.headline)

                Text(serverStatusMessage)
                    .font(.subheadline)
                    .foregroundColor(isServerRunning ? .green : .red)

                Text("Endpoint: \(networkingManager.healthCheckEndpointString)")
                    .font(.system(.body, design: .monospaced))
                    .padding(10)
                    .cornerRadius(8)

            }
            .padding()
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            checkServerStatus()
        }
        .onReceive(timer) { _ in
            checkServerStatus()
        }
    }

    // Check if the server is responding
    private func checkServerStatus() {
        guard let url = networkingManager.healthCheckURL else { return }

        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.isServerRunning = true
                    self.serverStatusMessage = "Server Status: Running ✓"
                } else {
                    self.isServerRunning = false
                    if let error = error {
                        self.serverStatusMessage = "Server Error: \(error.localizedDescription)"
                    } else {
                        self.serverStatusMessage = "Server Status: Not responding"
                    }
                }
            }
        }
        task.resume()
    }
}

#Preview {
    ContentView()
}
