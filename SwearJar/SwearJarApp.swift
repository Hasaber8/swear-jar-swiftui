//
//  SwearJarApp.swift
//  SwearJar
//
//  Created by Rohan Hasabe on 27/03/25.
//

import SwiftUI
import UIKit

// App Delegate to handle app lifecycle events
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Log current UserDefaults values at launch for debugging
        let hasLaunchedBefore = true
        let currentUserId = UserDefaults.standard.integer(forKey: "currentUserId")
        print("APP LAUNCH: hasLaunchedBefore = \(hasLaunchedBefore), currentUserId = \(currentUserId)")
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Force synchronize UserDefaults when app terminates
        UserDefaults.standard.synchronize()
        
        // Log values for debugging
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        let currentUserId = UserDefaults.standard.integer(forKey: "currentUserId")
        print("APP TERMINATE: hasLaunchedBefore = \(hasLaunchedBefore), currentUserId = \(currentUserId)")
    }
}

@main
struct SwearJarApp: App {
    // Register app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Track scene phase changes
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // Log values when app becomes active
                let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
                let currentUserId = UserDefaults.standard.integer(forKey: "currentUserId")
                print("SCENE BECAME ACTIVE: hasLaunchedBefore = \(hasLaunchedBefore), currentUserId = \(currentUserId)")
                
            case .inactive:
                // App is transitioning to inactive state
                print("SCENE BECAME INACTIVE")
                
            case .background:
                // App is entering background
                // Force synchronize UserDefaults when app moves to background
                UserDefaults.standard.synchronize()
                
                // Log values
                let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
                let currentUserId = UserDefaults.standard.integer(forKey: "currentUserId")
                print("SCENE BACKGROUND: hasLaunchedBefore = \(hasLaunchedBefore), currentUserId = \(currentUserId)")
                
            @unknown default:
                break
            }
        }
    }
}
