//
//  IntentHandler.swift
//  apple-mcp
//

import Intents

// Protocol for the custom delete note intent
protocol DeleteNoteIntentHandling: NSObjectProtocol {
    func handle(intent: DeleteNoteIntent, completion: @escaping (DeleteNoteIntentResponse) -> Void)
}

// Response class for the custom delete note intent
class DeleteNoteIntentResponse: INIntentResponse {
    // No properties needed for a simple success/failure response
}

class IntentHandler: INExtension {

    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is DeleteNoteIntent:
            return self
        default:
            return self
        }
    }

}

// MARK: - DeleteNoteIntentHandling
extension IntentHandler: DeleteNoteIntentHandling {

    func handle(intent: DeleteNoteIntent, completion: @escaping (DeleteNoteIntentResponse) -> Void) {
        guard let noteIdString = intent.note?.identifier,
              let noteId = UUID(uuidString: noteIdString) else {
            completion(DeleteNoteIntentResponse(code: .failure, userActivity: nil))
            return
        }

        if NoteStore.shared.deleteNote(byId: noteId) {
            completion(DeleteNoteIntentResponse(code: .success, userActivity: nil))
        } else {
            completion(DeleteNoteIntentResponse(code: .failure, userActivity: nil))
        }
    }

}

// MARK: - INSearchForNotebookItemsIntentHandling
extension IntentHandler: INSearchForNotebookItemsIntentHandling {

    func handle(intent: INSearchForNotebookItemsIntent, completion: @escaping (INSearchForNotebookItemsIntentResponse) -> Void) {
        let allNotes = NoteStore.shared.getAllNotes()

        let inNotes = allNotes.map { note in
            INNote(
                title: INSpeakableString(spokenPhrase: note.title),
                contents: [INTextNoteContent(text: note.content)],
                groupName: nil,
                createdDateComponents: Calendar.current.dateComponents(in: .current, from: note.createdAt),
                modifiedDateComponents: Calendar.current.dateComponents(in: .current, from: note.updatedAt),
                identifier: note.id.uuidString
            )
        }

        let response = INSearchForNotebookItemsIntentResponse(code: .success, userActivity: nil)
        response.notes = inNotes
        completion(response)
    }

}

// MARK: - INAppendToNoteIntentHandling
extension IntentHandler: INAppendToNoteIntentHandling {

    func handle(intent: INAppendToNoteIntent, completion: @escaping (INAppendToNoteIntentResponse) -> Void) {
        guard let noteIdString = intent.targetNote?.identifier,
              let noteId = UUID(uuidString: noteIdString),
              let content = (intent.content as? INTextNoteContent)?.text else {
            completion(INAppendToNoteIntentResponse(code: .failure, userActivity: nil))
            return
        }

        guard let existingNote = NoteStore.shared.getNote(byId: noteId) else {
            completion(INAppendToNoteIntentResponse(code: .failure, userActivity: nil))
            return
        }

        let updatedContent = existingNote.content + "\n" + content

        if let updatedNote = NoteStore.shared.updateNote(byId: noteId, title: existingNote.title, content: updatedContent) {
            let response = INAppendToNoteIntentResponse(code: .success, userActivity: nil)
            response.note = INNote(
                title: INSpeakableString(spokenPhrase: updatedNote.title),
                contents: [INTextNoteContent(text: updatedNote.content)],
                groupName: nil,
                createdDateComponents: Calendar.current.dateComponents(in: .current, from: updatedNote.createdAt),
                modifiedDateComponents: Calendar.current.dateComponents(in: .current, from: updatedNote.updatedAt),
                identifier: updatedNote.id.uuidString
            )
            completion(response)
        } else {
            completion(INAppendToNoteIntentResponse(code: .failure, userActivity: nil))
        }
    }

}

// MARK: - INCreateNoteIntentHandling
extension IntentHandler: INCreateNoteIntentHandling {

    func handle(intent: INCreateNoteIntent, completion: @escaping (INCreateNoteIntentResponse) -> Void) {
        guard let title = intent.title,
              let content = intent.content else {
            completion(INCreateNoteIntentResponse(code: .failure, userActivity: nil))
            return
        }

        let note = NoteStore.shared.createNote(title: title.spokenPhrase ?? "", content: (content as? INTextNoteContent)?.text ?? "")

        let response = INCreateNoteIntentResponse(code: .success, userActivity: nil)
        response.createdNote = INNote(
            title: INSpeakableString(spokenPhrase: note.title),
            contents: [INTextNoteContent(text: note.content)],
            groupName: nil,
            createdDateComponents: Calendar.current.dateComponents(in: .current, from: note.createdAt),
            modifiedDateComponents: Calendar.current.dateComponents(in: .current, from: note.updatedAt),
            identifier: note.id.uuidString
        )
        completion(response)
    }

}
