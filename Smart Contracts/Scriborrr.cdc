// There are different access levels(https://docs.onflow.org/cadence/language/access-control/#gatsby-focus-wrapper) 
// For the contract to be accessible from outside we will define it as public (pub). 

pub contract NotepadManagerV1 {

    pub var numberOfNotepadsCreated: UInt64

	pub resource Notepad {

        // We will use a dictionary of resources to store the notes.
        pub var notes: @{UInt64 : Note}

        init() {
            // We initialize the dictionary with an empty dictionary.
            self.notes <- {}
        }

        // We need to destroy the nested resources when the Notepad resource is destroyed.
        destroy() {
            destroy self.notes
        }

        // Public method to add a new note
        pub fun addNote(title: String, body: String) {
            let oldNote <- self.notes[note.uuid] <- note
            destroy oldNote
        }

        // Public method to edit an existing note.
        pub fun editNote(noteID: UInt64, newTitle: String, newBody: String) {
            // Move the desired note out from the dictionary (to a constant) and destroy it:
            let oldNote <- self.notes.insert(key: noteID, <- create Note(title: newTitle, body: newBody))
            destroy oldNote
        }

        // Public method to delete an existing note from the Notepad.
        pub fun deleteNote(noteID: UInt64) {
            // Move the desired note out from the dictionary (to a constant) and destroy it: 
            let note <- self.notes.remove(key: noteID)
            destroy note
        }

        // Public method to get a note by its ID.
        pub fun note(noteID: UInt64): NoteDTO {
            var note <- self.notes.remove(key: noteID)!
            let noteDTO = NoteDTO(id: noteID, title: note.title, body: note.body)
            
            let oldNote <- self.notes[noteID] <- note
            destroy oldNote
            return noteDTO
        }

        // Public method to get all the notes.
        pub fun allNotes(): [NoteDTO] { 
            var allNotes: [NoteDTO] = []
            for key in self.notes.keys {
                allNotes.append(self.note(noteID: key))
            }

            return allNotes
        }
	}

    // Resource that represents a Note
	pub resource Note {
        pub(set) var title: String
        pub(set) var body: String

        init(title: String, body: String) {
            self.title = title 
            self.body = body
        }
	}

    // Struct that represents a NoteDTO(Data Transfer Object)
    pub struct NoteDTO {
        pub let id: UInt64
        pub let title: String
        pub let body: String

        init(id: UInt64, title: String, body: String) {
            self.id = id
            self.title = title 
            self.body = body
        }
    }

    init() {
        self.numberOfNotepadsCreated = 0
    }

    // Public method to create and return a Notepad Resource.
    pub fun createNotepad(): @Notepad {
        self.numberOfNotepadsCreated = self.numberOfNotepadsCreated + 1
        return <- create Notepad()
    }

    // Public method to delete a Notepad Resource.
    pub fun deleteNotepad(notepad: @Notepad) {
        self.numberOfNotepadsCreated = self.numberOfNotepadsCreated > 0 ? self.numberOfNotepadsCreated - 1 : 0
        destroy notepad
    }
}

