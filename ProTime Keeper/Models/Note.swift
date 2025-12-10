//
//  Note.swift
//  ProTime Keeper
//
//  Created on 2025
//

import Foundation

struct Note: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var content: String
    var category: NoteCategory
    var tags: [String]
    var createdAt: Date
    var modifiedAt: Date
    var isPinned: Bool
    
    enum NoteCategory: String, Codable, CaseIterable {
        case personal = "Personal"
        case work = "Work"
        case ideas = "Ideas"
        case meeting = "Meeting"
        case project = "Project"
        case other = "Other"
        
        var color: String {
            switch self {
            case .personal: return "#28a809"
            case .work: return "#d17305"
            case .ideas: return "#e6053a"
            case .meeting: return "#9b59b6"
            case .project: return "#3498db"
            case .other: return "#95a5a6"
            }
        }
        
        var icon: String {
            switch self {
            case .personal: return "person.fill"
            case .work: return "briefcase.fill"
            case .ideas: return "lightbulb.fill"
            case .meeting: return "calendar"
            case .project: return "folder.fill"
            case .other: return "note.text"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        category: NoteCategory = .other,
        tags: [String] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.isPinned = isPinned
    }
}

