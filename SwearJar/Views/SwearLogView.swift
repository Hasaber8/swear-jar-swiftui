//
//  SwearLogView.swift
//  SwearJar
//
//  Created for SwearJar app
//

import SwiftUI

struct SwearLogView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var swearLogViewModel = SwearLogViewModel()
    @StateObject private var swearWordViewModel = SwearWordViewModel()
    
    @State private var selectedWordId: Int?
    @State private var selectedMood: SwearLog.Mood?
    @State private var context: String = ""
    @State private var fineAmount: Double = 1.00
    @State private var showingConfirmation = false
    
    // For the mood selector
    let moodOptions: [SwearLog.Mood] = [.angry, .frustrated, .surprised, .amused, .stressed, .other]
    
    var body: some View {
        NavigationView {
            Form {
                // Word selection section
                Section(header: Text("I just swore...")) {
                    Picker("Select Word", selection: $selectedWordId) {
                        Text("Select a word").tag(nil as Int?)
                        ForEach(swearWordViewModel.swearWords) { word in
                            Text(word.word).tag(word.id as Int?)
                        }
                    }
                    
                    if let wordId = selectedWordId,
                       let word = swearWordViewModel.swearWords.first(where: { $0.id == wordId }) {
                        HStack {
                            Text("Severity")
                            Spacer()
                            Text(word.severity.rawValue.capitalized)
                                .foregroundColor(severityColor(word.severity))
                        }
                    }
                }
                
                // Mood and context section
                Section(header: Text("How did it feel?")) {
                    Picker("Mood", selection: $selectedMood) {
                        Text("Select a mood").tag(nil as SwearLog.Mood?)
                        ForEach(moodOptions, id: \.self) { mood in
                            Text(mood.rawValue.capitalized).tag(mood as SwearLog.Mood?)
                        }
                    }
                    
                    TextField("Context (optional)", text: $context)
                }
                
                // Fine amount section
                Section(header: Text("Fine Amount")) {
                    HStack {
                        Text("$")
                        TextField("Amount", value: $fineAmount, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                    
                    Stepper("$\(fineAmount, specifier: "%.2f")", value: $fineAmount, in: 0.25...10.00, step: 0.25)
                }
                
                // Submit button
                Section {
                    Button(action: logSwear) {
                        HStack {
                            Spacer()
                            Text("Log Swear")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(selectedWordId == nil)
                }
                
                // Recent logs section
                Section(header: Text("Recent Logs")) {
                    if swearLogViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if swearLogViewModel.recentLogs.isEmpty {
                        Text("No recent logs")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(swearLogViewModel.recentLogs.prefix(5)) { log in
                            logRow(for: log)
                        }
                    }
                }
            }
            .navigationTitle("Log Swear")
            .onAppear {
                if let userId = userViewModel.user?.id {
                    swearLogViewModel.setActiveUser(userId: userId)
                    // No need to call fetchSwearWords() - it's done in the ViewModel's init
                }
            }
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("Swear Logged"),
                    message: Text("Your swear has been recorded and a fine of $\(fineAmount, specifier: "%.2f") has been added."),
                    dismissButton: .default(Text("OK")) {
                        // Reset form after successful log
                        resetForm()
                    }
                )
            }
        }
    }
    
    private func logRow(for log: SwearLog) -> some View {
        HStack {
            VStack(alignment: .leading) {
                if let word = swearWordViewModel.swearWords.first(where: { $0.id == log.wordId }) {
                    Text(word.word)
                        .font(.headline)
                } else {
                    Text("Unknown word")
                        .font(.headline)
                }
                
                Text(formatDate(log.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(log.fineAmount, specifier: "%.2f")")
                .fontWeight(.semibold)
        }
    }
    
    private func logSwear() {
        guard let wordId = selectedWordId else { return }
        
        let newLog = swearLogViewModel.logSwearEvent(
            wordId: wordId,
            mood: selectedMood,
            context: context.isEmpty ? nil : context,
            fineAmount: fineAmount
        )
        
        if newLog != nil {
            // Update user stats
            userViewModel.incrementSwearStats(fineAmount: fineAmount)
            showingConfirmation = true
        }
    }
    
    private func resetForm() {
        selectedWordId = nil
        selectedMood = nil
        context = ""
        fineAmount = 1.00
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
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

struct SwearLogView_Previews: PreviewProvider {
    static var previews: some View {
        SwearLogView(userViewModel: UserViewModel())
    }
}
