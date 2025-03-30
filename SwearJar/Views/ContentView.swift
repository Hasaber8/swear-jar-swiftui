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
    
    /// Whether user has completed onboarding
    @AppStorage("hasLaunchedBefore") private var onboardingCompleted: Bool = false
    
    /// Current user ID
    @AppStorage("currentUserId") private var currentUserId: Int = 1
    
    // View models
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var settingsViewModel = UserSettingsViewModel()
    
    // MARK: - Body
    
    var body: some View {
        if !onboardingCompleted {
            // Show onboarding
            OnboardingView(isFirstLaunch: $onboardingCompleted)
        } else {
            // Show main app with tabs
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
                loadUser()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadUser() {
        userViewModel.fetchUserDetails(userId: currentUserId)
        settingsViewModel.setActiveUser(userId: currentUserId)
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

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    @State private var currentPage = 0
    @State private var username = ""
    @State private var displayName = ""
    @StateObject private var userViewModel = UserViewModel()
    
    let pages = [
        OnboardingPage(title: "Welcome to SwearJar",
                       description: "Track your swear words and build better habits.",
                       imageName: "speech.bubble"),
        OnboardingPage(title: "Monitor Your Progress",
                       description: "See your improvement over time with detailed statistics.",
                       imageName: "chart.bar"),
        OnboardingPage(title: "Build Streaks",
                       description: "Stay clean and build streaks of swear-free days.",
                       imageName: "flame.fill"),
        OnboardingPage(title: "Create Account",
                       description: "Get started with a free account.",
                       imageName: "person.crop.circle.badge.plus")
    ]
    
    var body: some View {
        VStack {
            if currentPage < pages.count - 1 {
                // Regular onboarding pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count - 1) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Button(action: {
                    if currentPage < pages.count - 2 {
                        currentPage += 1
                    } else {
                        currentPage = pages.count - 1
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                // Account creation page
                ScrollView {
                    VStack(spacing: 20) {
                        Image(systemName: pages.last?.imageName ?? "")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding()
                        
                        Text(pages.last?.title ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(pages.last?.description ?? "")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        
                        VStack(alignment: .leading) {
                            Text("Username")
                                .font(.headline)
                            
                            TextField("Choose a username", text: $username)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .autocapitalization(.none)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            Text("Display Name")
                                .font(.headline)
                            
                            TextField("Enter your name", text: $displayName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        Button(action: createAccount) {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.blue : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        Button(action: skipOnboarding) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    .padding()
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && !displayName.isEmpty && username.count >= 3
    }
    
    private func createAccount() {
        // Create the user using the service
        userViewModel.createUser(username: username, displayName: displayName)
        
        // After creating, the user should be available in the view model
        if let userId = userViewModel.user?.id {
            // Save user ID for future app launches
            UserDefaults.standard.set(userId, forKey: "currentUserId")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            isFirstLaunch = false
        } else {
            // Handle error - could display an alert here
            print("Failed to create user account")
        }
    }
    
    private func skipOnboarding() {
        // Create a default user with a random username
        let username = "user\(Int.random(in: 1000...9999))"
        let newUser = userViewModel.createUser(username: username, displayName: "User")
        
        if let userId = userViewModel.user?.id {
            // Save user ID for future app launches
            UserDefaults.standard.set(userId, forKey: "currentUserId")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            isFirstLaunch = false
        } else {
            // Handle error
            print("Failed to create default user account")
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding()
            
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
