//
//  NoteViewModel.swift
//  ProTime Keeper
//
//  Created on 2025
//

import Foundation
import Combine

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Note.NoteCategory?
    
    private let dataService = DataService.shared
    
    init() {
        loadNotes()
    }
    
    var filteredNotes: [Note] {
        var filtered = notes
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered.sorted { first, second in
            if first.isPinned != second.isPinned {
                return first.isPinned
            }
            return first.modifiedAt > second.modifiedAt
        }
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = note
            updatedNote.modifiedAt = Date()
            notes[index] = updatedNote
            saveNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    func togglePin(_ note: Note) {
        var updatedNote = note
        updatedNote.isPinned.toggle()
        updateNote(updatedNote)
    }
    
    private func loadNotes() {
        notes = dataService.loadNotes()
    }
    
    private func saveNotes() {
        dataService.saveNotes(notes)
    }
}

