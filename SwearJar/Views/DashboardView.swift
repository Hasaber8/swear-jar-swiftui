//
//  DashboardView.swift
//  SwearJar
//
//  Created for SwearJar app
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var dailySummaryViewModel = DailySummaryViewModel()
    @StateObject private var streakViewModel = StreakHistoryViewModel()
    @StateObject private var swearLogViewModel = SwearLogViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User greeting section
                    greetingSection
                    
                    // Current streak section
                    streakSection
                    
                    // Today's summary section
                    todaySummarySection
                    
                    // Recent swears section
                    recentSwearsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                loadData()
            }
            .refreshable {
                loadData()
            }
        }
    }
    
    private func loadData() {
        if let userId = userViewModel.user?.id {
            // Set active user for each view model
            dailySummaryViewModel.setActiveUser(userId: userId)
            streakViewModel.setActiveUser(userId: userId)
            swearLogViewModel.setActiveUser(userId: userId)
            
            // Fetch user details again
            userViewModel.fetchUserDetails(userId: userId)
        }
    }
    
    // MARK: - UI Components
    
    private var greetingSection: some View {
        VStack(alignment: .leading) {
            Text("Hello, \(userViewModel.user?.displayName ?? "Swearer")")
                .font(.title)
                .fontWeight(.bold)
                
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Swears")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(userViewModel.totalSwears)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Total Fines")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("$\(userViewModel.totalFines, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var streakSection: some View {
        VStack(alignment: .leading) {
            Text("Current Streak")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    if let currentStreak = streakViewModel.currentStreak {
                        let days = Calendar.current.dateComponents([.day], from: currentStreak.startDate, to: Date()).day ?? 0
                        Text("\(days) days clean")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Started \(formatDate(currentStreak.startDate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No active streak")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Start your clean streak today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundColor(streakViewModel.currentStreak != nil ? .orange : .gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var todaySummarySection: some View {
        VStack(alignment: .leading) {
            Text("Today's Summary")
                .font(.headline)
            
            if dailySummaryViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let summary = dailySummaryViewModel.todaySummary {
                HStack {
                    VStack(alignment: .leading) {
                        Text(summary.isCleanDay ? "Clean Day 🎉" : "Swears Today: \(summary.swearCount)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        if !summary.isCleanDay {
                            Text("$\(summary.totalFine, specifier: "%.2f") in fines")
                                .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                    
                    // Status icon
                    Image(systemName: summary.isCleanDay ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(summary.isCleanDay ? .green : .red)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            } else {
                Text("No summary available for today")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
        }
    }
    
    private var recentSwearsSection: some View {
        VStack(alignment: .leading) {
            Text("Recent Activity")
                .font(.headline)
            
            if swearLogViewModel.recentLogs.isEmpty {
                Text("No recent activity")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
            } else {
                ForEach(swearLogViewModel.recentLogs.prefix(5)) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Swear logged")
                                .font(.headline)
                            Text(formatDate(log.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("$\(log.fineAmount, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 1)
                }
            }
            
            Button("View Full History") {
                // This will be connected to a history view later
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.top, 5)
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(userViewModel: UserViewModel())
    }
}
