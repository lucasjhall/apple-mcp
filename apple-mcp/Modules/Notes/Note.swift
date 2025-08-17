//
//  Note.swift
//  apple-mcp
//

import Foundation

// Represents a single note with a unique ID, title, and content
struct Note: Codable, Identifiable {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    // Initialize a new note
    init(title: String, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
