//
//  MainTabView.swift
//  SwearJar
//
//  Created for SwearJar app
//

import SwiftUI

struct MainTabView: View {
    // Shared ViewModels that need to be accessible across tabs
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var settingsViewModel = UserSettingsViewModel()
    
    // Track currently selected tab
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard tab
            DashboardView(userViewModel: userViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
                .tag(0)
            
            // Swear Log tab
            SwearLogView(userViewModel: userViewModel)
                .tabItem {
                    Label("Log", systemImage: "square.and.pencil")
                }
                .tag(1)
            
            // Stats tab
            StatsView(userViewModel: userViewModel)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(2)
            
            // Settings tab
            SettingsView(userViewModel: userViewModel, settingsViewModel: settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .onAppear {
            // Load the most recent user or show onboarding if no user exists
            loadUser()
        }
    }
    
    private func loadUser() {
        // For now, we'll load user with ID 1
        // In a real app, you'd use UserDefaults or another method to track the current user
        userViewModel.fetchUserDetails(userId: 1)
        settingsViewModel.setActiveUser(userId: 1)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
