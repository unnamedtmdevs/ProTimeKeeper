//
//  TaskView.swift
//  ProTime Keeper
//
//  Created on 2025
//

import SwiftUI

struct TaskView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var editingTask: Task?
    
    var body: some View {
        ZStack {
            Color(hex: "#0e0e0e")
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Tasks")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showingAddTask = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "#28a809"))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.5))
                        
                        TextField("Search tasks...", text: $viewModel.searchText)
                            .foregroundColor(.white)
                            .accentColor(Color(hex: "#28a809"))
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    
                    // Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TaskViewModel.TaskFilter.allCases, id: \.self) { filter in
                                FilterButton(
                                    title: filter.rawValue,
                                    isSelected: viewModel.selectedFilter == filter
                                ) {
                                    viewModel.selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 16)
                
                // Task List
                if viewModel.filteredTasks.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "No Tasks",
                        message: viewModel.searchText.isEmpty ? "Tap + to create your first task" : "No tasks match your search"
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredTasks) { task in
                            TaskRowView(task: task)
                                .environmentObject(viewModel)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .onTapGesture {
                                    editingTask = task
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTask(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        editingTask = task
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color(hex: "#d17305"))
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        viewModel.toggleTaskCompletion(task)
                                    } label: {
                                        Label(task.isCompleted ? "Incomplete" : "Complete", systemImage: task.isCompleted ? "xmark" : "checkmark")
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
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showingAddTask) {
            TaskEditorView(viewModel: viewModel)
        }
        .sheet(item: $editingTask) { task in
            TaskEditorView(viewModel: viewModel, task: task)
        }
    }
}

struct TaskRowView: View {
    let task: Task
    @EnvironmentObject var viewModel: TaskViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                viewModel.toggleTaskCompletion(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.isCompleted ? Color(hex: "#28a809") : .white.opacity(0.3))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Status Indicator
            Circle()
                .fill(Color(hex: task.priority.color))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(task.deadline, style: .date)
                        .font(.system(size: 14))
                    
                    Text("•")
                    
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(task.deadline, style: .time)
                        .font(.system(size: 14))
                }
                .foregroundColor(task.isOverdue ? Color(hex: "#e6053a") : .white.opacity(0.6))
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if task.isOverdue && !task.isCompleted {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#e6053a"))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct TaskEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    let task: Task?
    
    @State private var title: String
    @State private var description: String
    @State private var deadline: Date
    @State private var priority: Task.Priority
    @State private var category: String
    
    init(viewModel: TaskViewModel, task: Task? = nil) {
        self.viewModel = viewModel
        self.task = task
        
        _title = State(initialValue: task?.title ?? "")
        _description = State(initialValue: task?.description ?? "")
        _deadline = State(initialValue: task?.deadline ?? Date().addingTimeInterval(3600))
        _priority = State(initialValue: task?.priority ?? .medium)
        _category = State(initialValue: task?.category ?? "General")
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
                            
                            TextField("Task title", text: $title)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextEditor(text: $description)
                                .foregroundColor(.white)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Deadline
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deadline")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .accentColor(Color(hex: "#28a809"))
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 12) {
                                ForEach(Task.Priority.allCases, id: \.self) { p in
                                    Button(action: {
                                        priority = p
                                    }) {
                                        Text(p.rawValue)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(priority == p ? .white : .white.opacity(0.6))
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity)
                                            .background(priority == p ? Color(hex: p.color) : Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Category", text: $category)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
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
                        saveTask()
                    }
                    .foregroundColor(Color(hex: "#28a809"))
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        if let existingTask = task {
            let updatedTask = Task(
                id: existingTask.id,
                title: title,
                description: description,
                deadline: deadline,
                isCompleted: existingTask.isCompleted,
                priority: priority,
                category: category,
                createdAt: existingTask.createdAt
            )
            viewModel.updateTask(updatedTask)
        } else {
            let newTask = Task(
                title: title,
                description: description,
                deadline: deadline,
                priority: priority,
                category: category
            )
            viewModel.addTask(newTask)
        }
        dismiss()
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "#28a809") : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

