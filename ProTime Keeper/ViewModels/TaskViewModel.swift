//
//  TaskViewModel.swift
//  ProTime Keeper
//
//  Created on 2025
//

import Foundation
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: TaskFilter = .all
    
    private let dataService = DataService.shared
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        case overdue = "Overdue"
    }
    
    init() {
        loadTasks()
    }
    
    var filteredTasks: [Task] {
        let filtered: [Task]
        
        switch selectedFilter {
        case .all:
            filtered = tasks
        case .active:
            filtered = tasks.filter { !$0.isCompleted }
        case .completed:
            filtered = tasks.filter { $0.isCompleted }
        case .overdue:
            filtered = tasks.filter { $0.isOverdue }
        }
        
        if searchText.isEmpty {
            return filtered.sorted { $0.deadline < $1.deadline }
        }
        
        return filtered.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText) ||
            task.description.localizedCaseInsensitiveContains(searchText) ||
            task.category.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.deadline < $1.deadline }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
    }
    
    private func loadTasks() {
        tasks = dataService.loadTasks()
    }
    
    private func saveTasks() {
        dataService.saveTasks(tasks)
    }
}

