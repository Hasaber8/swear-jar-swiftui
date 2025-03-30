//
//  StatsView.swift
//  SwearJar
//
//  Created for SwearJar app
//

import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var dailySummaryViewModel = DailySummaryViewModel()
    @StateObject private var streakViewModel = StreakHistoryViewModel()
    @StateObject private var swearLogViewModel = SwearLogViewModel()
    @StateObject private var swearWordViewModel = SwearWordViewModel()
    
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time range selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Streak stats
                    streakStatsSection
                    
                    // Swear frequency chart
                    swearFrequencySection
                    
                    // Top swear words
                    topSwearWordsSection
                    
                    // Fine summary
                    fineSummarySection
                    
                    // Progress comparison
                    progressSection
                }
                .padding(.bottom)
            }
            .navigationTitle("Statistics")
            .onAppear {
                if let userId = userViewModel.user?.id {
                    dailySummaryViewModel.setActiveUser(userId: userId)
                    streakViewModel.setActiveUser(userId: userId)
                    swearLogViewModel.setActiveUser(userId: userId)
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    private var streakStatsSection: some View {
        VStack(alignment: .leading) {
            Text("Clean Streaks")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                streakStatCard(
                    title: "Current Streak",
                    value: streakViewModel.currentStreak != nil ? "\(calculateDaysBetween(streakViewModel.currentStreak!.startDate, Date()))" : "0",
                    subtitle: "days",
                    iconName: "flame.fill",
                    iconColor: .orange
                )
                
                streakStatCard(
                    title: "Longest Streak",
                    value: streakViewModel.longestStreak != nil ? "\(calculateDaysBetween(streakViewModel.longestStreak!.startDate, streakViewModel.longestStreak!.endDate ?? Date()))" : "0",
                    subtitle: "days",
                    iconName: "crown.fill",
                    iconColor: .yellow
                )
            }
            .padding(.horizontal)
            
            HStack(spacing: 15) {
                streakStatCard(
                    title: "Clean Days",
                    value: "\(dailySummaryViewModel.cleanDays)",
                    subtitle: "total",
                    iconName: "checkmark.circle.fill",
                    iconColor: .green
                )
                
                streakStatCard(
                    title: "Success Rate",
                    value: calculateSuccessRate(),
                    subtitle: "clean days",
                    iconName: "chart.bar.fill",
                    iconColor: .blue
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var swearFrequencySection: some View {
        VStack(alignment: .leading) {
            Text("Swear Frequency")
                .font(.headline)
                .padding(.horizontal)
            
            if #available(iOS 16.0, *) {
                let data = prepareChartData()
                
                Chart(data) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(Color.red.gradient)
                }
                .frame(height: 200)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
            } else {
                // Fallback for iOS 15 and earlier
                Text("Chart requires iOS 16 or later")
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
            }
        }
    }
    
    private var topSwearWordsSection: some View {
        VStack(alignment: .leading) {
            Text("Top Swear Words")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                ForEach(swearWordViewModel.mostSevereWords.prefix(5)) { word in
                    HStack {
                        Text(word.word)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(word.severity.rawValue.capitalized)
                            .foregroundColor(severityColor(word.severity))
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 1)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var fineSummarySection: some View {
        VStack(alignment: .leading) {
            Text("Fine Summary")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                fineSummaryCard(
                    title: "Total Fines",
                    value: "$\(userViewModel.totalFines)",
                    iconName: "dollarsign.circle.fill",
                    iconColor: .green
                )
                
                fineSummaryCard(
                    title: getRangeText(),
                    value: "$\(calculateFinesForRange())",
                    iconName: "calendar",
                    iconColor: .blue
                )
            }
            .padding(.horizontal)
            
            HStack(spacing: 15) {
                fineSummaryCard(
                    title: "Average Per Day",
                    value: "$\(calculateAverageFinePerDay())",
                    iconName: "chart.line.uptrend.xyaxis",
                    iconColor: .purple
                )
                
                fineSummaryCard(
                    title: "Highest Day",
                    value: "$\(calculateHighestFineDay())",
                    iconName: "exclamationmark.triangle.fill",
                    iconColor: .red
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading) {
            Text("Your Progress")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("This Period")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(calculateSwearCountForPeriod(current: true))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(calculateSwearCountForPeriod(current: true) > calculateSwearCountForPeriod(current: false) ? .red : .green)
                }
                
                Spacer()
                
                Image(systemName: calculateSwearCountForPeriod(current: true) > calculateSwearCountForPeriod(current: false) ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(calculateSwearCountForPeriod(current: true) > calculateSwearCountForPeriod(current: false) ? .red : .green)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Previous")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(calculateSwearCountForPeriod(current: false))")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Views
    
    private func streakStatCard(title: String, value: String, subtitle: String, iconName: String, iconColor: Color) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func fineSummaryCard(title: String, value: String, iconName: String, iconColor: Color) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func calculateDaysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
    
    private func calculateSuccessRate() -> String {
        guard let userId = userViewModel.user?.id else { return "0%" }
        
        let calendar = Calendar.current
        let today = Date()
        let userCreationDate = userViewModel.user?.createdAt ?? today
        
        let totalDays = max(1, calculateDaysBetween(userCreationDate, today))
        let cleanDays = dailySummaryViewModel.cleanDays
        
        let percentage = Double(cleanDays) / Double(totalDays) * 100
        
        return String(format: "%.0f%%", percentage)
    }
    
    private func getRangeText() -> String {
        switch selectedTimeRange {
        case .week:
            return "This Week"
        case .month:
            return "This Month"
        case .year:
            return "This Year"
        case .all:
            return "All Time"
        }
    }
    
    private func calculateFinesForRange() -> Double {
        // In a real app, this would query the database for the selected time range
        // For now, we'll return a placeholder value based on the total
        switch selectedTimeRange {
        case .week:
            return userViewModel.totalFines * 0.2
        case .month:
            return userViewModel.totalFines * 0.5
        case .year:
            return userViewModel.totalFines * 0.8
        case .all:
            return userViewModel.totalFines
        }
    }
    
    private func calculateAverageFinePerDay() -> Double {
        guard let userId = userViewModel.user?.id else { return 0 }
        
        let calendar = Calendar.current
        let today = Date()
        let userCreationDate = userViewModel.user?.createdAt ?? today
        
        let totalDays = max(1, calculateDaysBetween(userCreationDate, today))
        
        return userViewModel.totalFines / Double(totalDays)
    }
    
    private func calculateHighestFineDay() -> Double {
        // In a real app, this would query the database for the highest daily fine
        // For now, we'll return a placeholder value
        return dailySummaryViewModel.recentSummaries.map { $0.totalFine }.max() ?? 0
    }
    
    private func calculateSwearCountForPeriod(current: Bool) -> Int {
        // In a real app, this would query the database for the specific periods
        // For now, we'll return placeholder values
        if current {
            return Int(Double(userViewModel.totalSwears) * 0.3)
        } else {
            return Int(Double(userViewModel.totalSwears) * 0.4)
        }
    }
    
    // For Chart data
    struct ChartData: Identifiable {
        let id = UUID()
        let date: String
        let count: Int
    }
    
    private func prepareChartData() -> [ChartData] {
        // In a real app, this would analyze the swear logs to create chart data
        // For now, we'll create sample data
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let sampleCounts = [3, 2, 5, 1, 4, 2, 0]
        
        return Array(zip(days, sampleCounts)).map { ChartData(date: $0.0, count: $0.1) }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(userViewModel: UserViewModel())
    }
}
