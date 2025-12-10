//
//  NoteView.swift
//  ProTime Keeper
//

import SwiftUI

struct NoteView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showingAddNote = false
    @State private var editingNote: Note?
    
    var body: some View {
        ZStack {
            Color(hex: "#0e0e0e")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Notes")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showingAddNote = true }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "#28a809"))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.5))
                        
                        TextField("Search notes...", text: $viewModel.searchText)
                            .foregroundColor(.white)
                            .accentColor(Color(hex: "#28a809"))
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(
                                title: "All",
                                isSelected: viewModel.selectedCategory == nil
                            ) {
                                viewModel.selectedCategory = nil
                            }
                            
                            ForEach(Note.NoteCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 16)
                
                // Notes List
                if viewModel.filteredNotes.isEmpty {
                    EmptyStateView(
                        icon: "note.text",
                        title: "No Notes",
                        message: viewModel.searchText.isEmpty ? "Tap the pencil to create your first note" : "No notes match your search"
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredNotes) { note in
                            NoteRowView(note: note, viewModel: viewModel)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .onTapGesture {
                                    editingNote = note
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteNote(note)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        editingNote = note
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color(hex: "#d17305"))
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        viewModel.togglePin(note)
                                    } label: {
                                        Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin.fill")
                                    }
                                    .tint(Color(hex: "#28a809"))
                                }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            NoteEditorView(viewModel: viewModel)
        }
        .sheet(item: $editingNote) { note in
            NoteEditorView(viewModel: viewModel, note: note)
        }
    }
}

struct NoteRowView: View {
    let note: Note
    @ObservedObject var viewModel: NoteViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(Color(hex: note.category.color).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: note.category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: note.category.color))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(note.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#d17305"))
                    }
                }
                
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    Text(note.category.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: note.category.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: note.category.color).opacity(0.2))
                        .cornerRadius(4)
                    
                    if !note.tags.isEmpty {
                        ForEach(note.tags.prefix(2), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        if note.tags.count > 2 {
                            Text("+\(note.tags.count - 2)")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                    
                    Text(note.modifiedAt, style: .relative)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct NoteEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NoteViewModel
    
    let note: Note?
    
    @State private var title: String
    @State private var content: String
    @State private var category: Note.NoteCategory
    @State private var tagInput: String = ""
    @State private var tags: [String]
    
    init(viewModel: NoteViewModel, note: Note? = nil) {
        self.viewModel = viewModel
        self.note = note
        
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
        _category = State(initialValue: note?.category ?? .other)
        _tags = State(initialValue: note?.tags ?? [])
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0e0e0e")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Note title", text: $title)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextEditor(text: $content)
                                .foregroundColor(.white)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(Note.NoteCategory.allCases, id: \.self) { cat in
                                    Button(action: {
                                        category = cat
                                    }) {
                                        HStack {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 16))
                                            Text(cat.rawValue)
                                                .font(.system(size: 15, weight: .semibold))
                                        }
                                        .foregroundColor(category == cat ? .white : .white.opacity(0.6))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(category == cat ? Color(hex: cat.color) : Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack {
                                TextField("Add tag...", text: $tagInput, onCommit: addTag)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                
                                Button(action: addTag) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "#28a809"))
                                }
                            }
                            
                            if !tags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(tags, id: \.self) { tag in
                                            HStack(spacing: 4) {
                                                Text("#\(tag)")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                                
                                                Button(action: {
                                                    tags.removeAll { $0 == tag }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color(hex: "#28a809").opacity(0.3))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .foregroundColor(Color(hex: "#28a809"))
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        tagInput = ""
    }
    
    private func saveNote() {
        if let existingNote = note {
            let updatedNote = Note(
                id: existingNote.id,
                title: title,
                content: content,
                category: category,
                tags: tags,
                createdAt: existingNote.createdAt,
                modifiedAt: Date(),
                isPinned: existingNote.isPinned
            )
            viewModel.updateNote(updatedNote)
        } else {
            let newNote = Note(
                title: title,
                content: content,
                category: category,
                tags: tags
            )
            viewModel.addNote(newNote)
        }
        dismiss()
    }
}

struct CategoryButton: View {
    let category: Note.NoteCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                Text(category.rawValue)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: category.color) : Color.white.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

