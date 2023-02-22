//
//  ProfilesApp.swift
//  Profiles
//
//  Created by Stephen Devlin on 13/09/2022.
//

import SwiftUI

@main

struct ProfilesApp: App {
  
    
    // This environment variable is the simplest way
    // I found for popping all windows in the
    // navigation view back to the root
    
    // By storing and then changing the UUID of the
    // root page - this pops all the children and
    // reloads the starting page
    
    @ObservedObject var appState = AppState()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
            
        }
    }
}



