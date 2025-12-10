//
//  Task.swift
//  ProTime Keeper
//
//  Created on 2025
//

import Foundation

struct Task: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var description: String
    var deadline: Date
    var isCompleted: Bool
    var priority: Priority
    var category: String
    var createdAt: Date
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
        
        var color: String {
            switch self {
            case .low: return "#28a809"
            case .medium: return "#d17305"
            case .high: return "#e6053a"
            case .urgent: return "#ff0066"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        deadline: Date,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        category: String = "General",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.createdAt = createdAt
    }
    
    var isOverdue: Bool {
        !isCompleted && deadline < Date()
    }
}

