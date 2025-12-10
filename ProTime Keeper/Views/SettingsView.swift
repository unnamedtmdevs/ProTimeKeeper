//
//  SettingsView.swift
//  ProTime Keeper
//
//  Created on 2025
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("shareEnabled") private var shareEnabled = false
    
    @State private var showingResetAlert = false
    
    var body: some View {
        ZStack {
            Color(hex: "#0e0e0e")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon & Version
                    VStack(spacing: 12) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#28a809"))
                        
                        Text("ProTime Keeper")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Collaboration Section
                    VStack(spacing: 0) {
                        SectionHeader(title: "Collaboration")
                        
                        SettingsRow {
                            Toggle(isOn: $shareEnabled) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(Color(hex: "#d17305"))
                                    Text("Enable Sharing")
                                        .foregroundColor(.white)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#28a809")))
                        }
                        
                        if shareEnabled {
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            SettingsRow {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Share Link")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("protime://share/\(UUID().uuidString.prefix(8))")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                    
                                    Button(action: {
                                        // Copy to clipboard
                                    }) {
                                        Text("Copy Link")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(hex: "#28a809"))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    
                    // About Section
                    VStack(spacing: 0) {
                        SectionHeader(title: "About")
                        
                        SettingsButton(
                            icon: "info.circle.fill",
                            title: "Show Onboarding",
                            color: "#28a809"
                        ) {
                            hasCompletedOnboarding = false
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        SettingsButton(
                            icon: "arrow.clockwise.circle.fill",
                            title: "Reset All Data",
                            color: "#e6053a"
                        ) {
                            showingResetAlert = true
                        }
                    }
                    
                    // Footer
                    Text("Made with ❤️ for productivity enthusiasts")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will delete all your tasks, notes, and time blocks. This action cannot be undone.")
        }
    }
    
    private func resetAllData() {
        UserDefaults.standard.removeObject(forKey: "protime_tasks")
        UserDefaults.standard.removeObject(forKey: "protime_notes")
        UserDefaults.standard.removeObject(forKey: "protime_timeblocks")
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }
}

struct SettingsRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: color))
                
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
        }
    }
}

