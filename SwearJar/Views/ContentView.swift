//
//  ContentView.swift
//  SwearJar
//
//  Created for SwearJar app
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    
    /// The active tab selection
    @State private var selectedTab: Tab = .dashboard
    
    // View models
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var settingsViewModel = UserSettingsViewModel()
    
    // MARK: - Body
    
    var body: some View {
        // Always show main app with tabs (bypass onboarding)
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationView {
                DashboardView(userViewModel: userViewModel)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(Tab.dashboard)
            
            // Swear Log Tab
            NavigationView {
                SwearLogView(userViewModel: userViewModel)
            }
            .tabItem {
                Label("Log", systemImage: "square.and.pencil")
            }
            .tag(Tab.swearLog)
            
            // Stats Tab
            NavigationView {
                StatsView(userViewModel: userViewModel)
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(Tab.stats)
            
            // Settings Tab
            NavigationView {
                SettingsView(userViewModel: userViewModel, settingsViewModel: settingsViewModel)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(Tab.settings)
        }
        .accentColor(.blue)
        .onAppear {
            // Load default user immediately
            loadDefaultUser()
        }
    }
    
    // MARK: - Helper Methods
    
    /// Load the default user (ID: 1, username: rohan)
    private func loadDefaultUser() {
        print("Loading default user (ID: 1, username: rohan)")
        
        // Set default user ID
        let defaultUserId = 1
        
        // Check if user exists, if not create it
        if userViewModel.getUserById(defaultUserId) == nil {
            print("Default user not found, creating it")
            userViewModel.createUser(username: "rohan", displayName: "Rohan")
        } else {
            print("Default user found, loading it")
            userViewModel.fetchUserDetails(userId: defaultUserId)
        }
        
        // Set the active user for settings
        settingsViewModel.setActiveUser(userId: defaultUserId)
    }
    
    // MARK: - Tab Enum
    
    /// Enum for app tabs
    enum Tab: Int {
        case dashboard
        case swearLog
        case stats
        case settings
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
