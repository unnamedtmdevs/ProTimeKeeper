//
//  DataService.swift
//  ProTime Keeper
//

import Foundation

class DataService {
    static let shared = DataService()
    
    private let tasksKey = "protime_tasks"
    private let notesKey = "protime_notes"
    private let timeBlocksKey = "protime_timeblocks"
    
    private init() {}
    
    // MARK: - Tasks
    
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    func loadTasks() -> [Task] {
        guard let data = UserDefaults.standard.data(forKey: tasksKey),
              let tasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return []
        }
        return tasks
    }
    
    // MARK: - Notes
    
    func saveNotes(_ notes: [Note]) {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    func loadNotes() -> [Note] {
        guard let data = UserDefaults.standard.data(forKey: notesKey),
              let notes = try? JSONDecoder().decode([Note].self, from: data) else {
            return []
        }
        return notes
    }
    
    // MARK: - Time Blocks
    
    func saveTimeBlocks(_ blocks: [TimeBlock]) {
        if let encoded = try? JSONEncoder().encode(blocks) {
            UserDefaults.standard.set(encoded, forKey: timeBlocksKey)
        }
    }
    
    func loadTimeBlocks() -> [TimeBlock] {
        guard let data = UserDefaults.standard.data(forKey: timeBlocksKey),
              let blocks = try? JSONDecoder().decode([TimeBlock].self, from: data) else {
            return []
        }
        return blocks
    }
}

// MARK: - TimeBlock Model

struct TimeBlock: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var category: String
    var isActive: Bool
    var completedMinutes: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        startTime: Date,
        endTime: Date,
        category: String = "Focus",
        isActive: Bool = false,
        completedMinutes: Int = 0
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.isActive = isActive
        self.completedMinutes = completedMinutes
    }
    
    var duration: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return Double(completedMinutes) / Double(duration)
    }
}

