//
//  NoteStore.swift
//  apple-mcp
//

import Foundation

// Manages a collection of notes in memory
class NoteStore {
    // Shared singleton instance
    static let shared = NoteStore()

    // In-memory storage for notes
    private var notes: [Note] = []

    // Private initializer to ensure singleton usage
    private init() {}

    // MARK: - CRUD Operations

    /// Create a new note and add it to the store
    func createNote(title: String, content: String) -> Note {
        let note = Note(title: title, content: content)
        notes.append(note)
        return note
    }

    /// Retrieve all notes from the store
    func getAllNotes() -> [Note] {
        return notes
    }

    /// Retrieve a single note by its ID
    func getNote(byId id: UUID) -> Note? {
        return notes.first { $0.id == id }
    }

    /// Update an existing note's title and content
    func updateNote(byId id: UUID, title: String, content: String) -> Note? {
        guard let index = notes.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        notes[index].title = title
        notes[index].content = content
        notes[index].updatedAt = Date()
        return notes[index]
    }

    /// Delete a note from the store by its ID
    func deleteNote(byId id: UUID) -> Bool {
        guard let index = notes.firstIndex(where: { $0.id == id }) else {
            return false
        }
        notes.remove(at: index)
        return true
    }
}
