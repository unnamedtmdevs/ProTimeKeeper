//
//  TimeBlockViewModel.swift
//  ProTime Keeper
//

import Foundation
import Combine

class TimeBlockViewModel: ObservableObject {
    @Published var timeBlocks: [TimeBlock] = []
    @Published var activeBlock: TimeBlock?
    
    private let dataService = DataService.shared
    private var timer: Timer?
    
    init() {
        loadTimeBlocks()
        startTimer()
    }
    
    var todayBlocks: [TimeBlock] {
        let calendar = Calendar.current
        return timeBlocks.filter { block in
            calendar.isDateInToday(block.startTime)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    func addTimeBlock(_ block: TimeBlock) {
        timeBlocks.append(block)
        saveTimeBlocks()
    }
    
    func updateTimeBlock(_ block: TimeBlock) {
        if let index = timeBlocks.firstIndex(where: { $0.id == block.id }) {
            timeBlocks[index] = block
            saveTimeBlocks()
        }
    }
    
    func deleteTimeBlock(_ block: TimeBlock) {
        timeBlocks.removeAll { $0.id == block.id }
        saveTimeBlocks()
    }
    
    func startBlock(_ block: TimeBlock) {
        var updatedBlock = block
        updatedBlock.isActive = true
        updateTimeBlock(updatedBlock)
        activeBlock = updatedBlock
    }
    
    func stopBlock(_ block: TimeBlock) {
        var updatedBlock = block
        updatedBlock.isActive = false
        updateTimeBlock(updatedBlock)
        if activeBlock?.id == block.id {
            activeBlock = nil
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateActiveBlock()
        }
    }
    
    private func updateActiveBlock() {
        guard var block = activeBlock else { return }
        
        let now = Date()
        if now >= block.startTime && now <= block.endTime {
            let elapsed = Int(now.timeIntervalSince(block.startTime) / 60)
            block.completedMinutes = min(elapsed, block.duration)
            updateTimeBlock(block)
            activeBlock = block
        } else if now > block.endTime {
            stopBlock(block)
        }
    }
    
    private func loadTimeBlocks() {
        timeBlocks = dataService.loadTimeBlocks()
        activeBlock = timeBlocks.first { $0.isActive }
    }
    
    private func saveTimeBlocks() {
        dataService.saveTimeBlocks(timeBlocks)
    }
    
    deinit {
        timer?.invalidate()
    }
}

