//
//  SettingsView.swift
//  SwearJar
//
//  Created for SwearJar app
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var settingsViewModel: UserSettingsViewModel
    
    @State private var newDisplayName: String = ""
    @State private var showReminderPicker: Bool = false
    @State private var selectedReminderTime: Date = Date()
    @State private var showDeleteConfirmation: Bool = false
    @State private var showResetConfirmation: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                // User profile section
                Section(header: Text("Profile")) {
                    if let user = userViewModel.user {
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(user.username)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Display Name")
                            Spacer()
                            
                            if newDisplayName.isEmpty {
                                Text(user.displayName ?? "")
                                    .foregroundColor(.secondary)
                            } else {
                                TextField("Display Name", text: $newDisplayName)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .onTapGesture {
                            if newDisplayName.isEmpty {
                                newDisplayName = user.displayName ?? ""
                            }
                        }
                        
                        Button(action: updateDisplayName) {
                            Text("Update Display Name")
                        }
                        .disabled(newDisplayName.isEmpty || newDisplayName == user.displayName)
                    }
                }
                
                // Notifications section
                Section(header: Text("Notifications")) {
                    Toggle("Daily Reminders", isOn: Binding(
                        get: { settingsViewModel.userSettings?.reminderTime != nil },
                        set: { newValue in
                            if newValue {
                                showReminderPicker = true
                            } else {
                                settingsViewModel.updateReminderTime(time: nil)
                            }
                        }
                    ))
                    
                    if settingsViewModel.userSettings?.reminderTime != nil {
                        HStack {
                            Text("Reminder Time")
                            Spacer()
                            Text(formatTime(settingsViewModel.userSettings?.reminderTime))
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            showReminderPicker = true
                        }
                    }
                }
                
                // App preferences section
                Section(header: Text("App Preferences")) {
                    Toggle("Dark Mode", isOn: Binding(
                        get: { settingsViewModel.userSettings?.darkMode ?? false },
                        set: { settingsViewModel.updateDarkMode(enabled: $0) }
                    ))
                    
                    Toggle("Share Stats", isOn: Binding(
                        get: { settingsViewModel.userSettings?.shareStats ?? false },
                        set: { settingsViewModel.updateShareStats(enabled: $0) }
                    ))
                    
                    Toggle("Auto Location", isOn: Binding(
                        get: { settingsViewModel.userSettings?.autoLocation ?? false },
                        set: { settingsViewModel.updateAutoLocation(enabled: $0) }
                    ))
                }
                
                // Word management
                Section(header: Text("Swear Words")) {
                    NavigationLink(destination: SwearWordManagementView()) {
                        Text("Manage Swear Words")
                    }
                }
                
                // Data management section
                Section(header: Text("Data Management")) {
                    Button(action: { showResetConfirmation = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.orange)
                            Text("Reset Statistics")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Button(action: { showDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // About section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://swearjar.app/privacy")!) {
                        Text("Privacy Policy")
                    }
                    
                    Link(destination: URL(string: "https://swearjar.app/terms")!) {
                        Text("Terms of Service")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showReminderPicker) {
                reminderTimePicker
            }
            .alert("Reset Statistics", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetStatistics()
                }
            } message: {
                Text("This will reset all your swear statistics, including your streak. This action cannot be undone.")
            }
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all associated data. This action cannot be undone.")
            }
        }
    }
    
    private var reminderTimePicker: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Reminder Time",
                    selection: $selectedReminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                
                Button("Save") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let timeString = formatter.string(from: selectedReminderTime)
                    settingsViewModel.updateReminderTime(time: timeString)
                    showReminderPicker = false
                }
                .buttonStyle(BorderedButtonStyle())
                .padding()
            }
            .navigationTitle("Reminder Time")
            .navigationBarItems(trailing: Button("Cancel") {
                showReminderPicker = false
            })
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ timeString: String?) -> String {
        guard let timeString = timeString else { return "Not set" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date = formatter.date(from: timeString) else {
            return timeString
        }
        
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func updateDisplayName() {
        guard !newDisplayName.isEmpty else { return }
        
        userViewModel.updateDisplayName(newDisplayName: newDisplayName)
        
        // Clear the field after update
        newDisplayName = ""
    }
    
    private func resetStatistics() {
        userViewModel.resetStatistics()
    }
    
    private func deleteAccount() {
        if userViewModel.deleteCurrentUser() {
            // In a real app, navigate to login screen or onboarding
            print("Account deleted successfully")
        } else {
            print("Failed to delete account")
        }
    }
}

struct SwearWordManagementView: View {
    @StateObject private var viewModel = SwearWordViewModel()
    @State private var showingAddSheet = false
    @State private var newWord = ""
    @State private var newSeverity = SwearWord.Severity.mild
    @State private var searchText = ""
    
    var filteredWords: [SwearWord] {
        if searchText.isEmpty {
            return viewModel.swearWords
        } else {
            return viewModel.searchWords(text: searchText)
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Search")) {
                TextField("Search words", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Section(header: HStack {
                Text("Dictionary")
                Spacer()
                Text("\(viewModel.swearWords.count) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }) {
                ForEach(filteredWords) { word in
                    HStack {
                        Text(word.word)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(word.severity.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(severityColor(word.severity))
                    }
                    .contextMenu {
                        Button(action: {
                            // Edit functionality would go here
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            viewModel.removeSwearWord(wordId: word.id!)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            
            Section {
                Button(action: { showingAddSheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Add New Word")
                    }
                }
            }
        }
        .navigationTitle("Swear Words")
        .sheet(isPresented: $showingAddSheet) {
            addWordSheet
        }
    }
    
    private var addWordSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("New Swear Word")) {
                    TextField("Word", text: $newWord)
                    
                    Picker("Severity", selection: $newSeverity) {
                        Text("Mild").tag(SwearWord.Severity.mild)
                        Text("Moderate").tag(SwearWord.Severity.moderate)
                        Text("Severe").tag(SwearWord.Severity.severe)
                    }
                }
                
                Section {
                    Button("Add Word") {
                        if !newWord.isEmpty {
                            viewModel.addSwearWord(word: newWord, severity: newSeverity)
                            newWord = ""
                            showingAddSheet = false
                        }
                    }
                    .disabled(newWord.isEmpty)
                }
            }
            .navigationTitle("Add Word")
            .navigationBarItems(trailing: Button("Cancel") {
                showingAddSheet = false
            })
        }
    }
    
    private func severityColor(_ severity: SwearWord.Severity) -> Color {
        switch severity {
        case .mild:
            return .blue
        case .moderate:
            return .orange
        case .severe:
            return .red
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            userViewModel: UserViewModel(),
            settingsViewModel: UserSettingsViewModel()
        )
    }
}
