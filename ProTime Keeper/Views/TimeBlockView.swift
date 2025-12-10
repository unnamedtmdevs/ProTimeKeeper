//
//  TimeBlockView.swift
//  ProTime Keeper
//

import SwiftUI

struct TimeBlockView: View {
    @StateObject private var viewModel = TimeBlockViewModel()
    @State private var showingAddBlock = false
    
    var body: some View {
        ZStack {
            Color(hex: "#0e0e0e")
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Time Blocks")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingAddBlock = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "#28a809"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Active Block Card
                if let activeBlock = viewModel.activeBlock {
                    ActiveBlockCard(block: activeBlock, viewModel: viewModel)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                
                // Today's Blocks
                Text("Today's Schedule")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                
                if viewModel.todayBlocks.isEmpty {
                    EmptyStateView(
                        icon: "timer",
                        title: "No Time Blocks",
                        message: "Create a time block to start tracking your focus time"
                    )
                } else {
                    List {
                        ForEach(viewModel.todayBlocks) { block in
                            TimeBlockRowView(block: block, viewModel: viewModel)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTimeBlock(block)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
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
        .sheet(isPresented: $showingAddBlock) {
            TimeBlockEditorView(viewModel: viewModel)
        }
    }
}

struct ActiveBlockCard: View {
    let block: TimeBlock
    @ObservedObject var viewModel: TimeBlockViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Now")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#28a809"))
                    
                    Text(block.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.stopBlock(block)
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#e6053a"))
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(block.completedMinutes) / \(block.duration) min")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(block.progress * 100))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#28a809"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(hex: "#28a809"))
                            .frame(width: geometry.size.width * block.progress, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#28a809").opacity(0.2), Color(hex: "#28a809").opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct TimeBlockRowView: View {
    let block: TimeBlock
    @ObservedObject var viewModel: TimeBlockViewModel
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Time Indicator
            VStack(spacing: 2) {
                Text(timeFormatter.string(from: block.startTime))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Rectangle()
                    .fill(Color(hex: "#d17305"))
                    .frame(width: 2, height: 30)
                
                Text(timeFormatter.string(from: block.endTime))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Block Info
            VStack(alignment: .leading, spacing: 6) {
                Text(block.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(block.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#d17305"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#d17305").opacity(0.2))
                        .cornerRadius(4)
                    
                    Text("\(block.duration) min")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                if block.completedMinutes > 0 {
                    ProgressView(value: block.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#28a809")))
                }
            }
            
            Spacer()
            
            // Action Button
            if !block.isActive && block.startTime <= Date() && block.endTime >= Date() {
                Button(action: {
                    viewModel.startBlock(block)
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#28a809"))
                }
            } else if block.isActive {
                Image(systemName: "waveform")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#28a809"))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct TimeBlockEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TimeBlockViewModel
    
    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var duration: Int = 25
    @State private var category: String = "Focus"
    
    private let durations = [15, 25, 30, 45, 60, 90, 120]
    
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
                            
                            TextField("Focus block title", text: $title)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Start Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Time")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .accentColor(Color(hex: "#28a809"))
                        }
                        
                        // Duration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration (minutes)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Picker("Duration", selection: $duration) {
                                ForEach(durations, id: \.self) { d in
                                    Text("\(d) min").tag(d)
                                }
                            }
                            .pickerStyle(.segmented)
                            .colorScheme(.dark)
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 12) {
                                ForEach(["Focus", "Meeting", "Break", "Learning"], id: \.self) { cat in
                                    Button(action: {
                                        category = cat
                                    }) {
                                        Text(cat)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(category == cat ? .white : .white.opacity(0.6))
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity)
                                            .background(category == cat ? Color(hex: "#d17305") : Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Time Block")
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
                        saveBlock()
                    }
                    .foregroundColor(Color(hex: "#28a809"))
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveBlock() {
        let endTime = startTime.addingTimeInterval(Double(duration * 60))
        let block = TimeBlock(
            title: title,
            startTime: startTime,
            endTime: endTime,
            category: category
        )
        viewModel.addTimeBlock(block)
        dismiss()
    }
}

