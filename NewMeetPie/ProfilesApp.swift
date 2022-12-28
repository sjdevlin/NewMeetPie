//
//  ProfilesApp.swift
//  Profiles
//
//  Created by Stephen Devlin on 13/09/2022.
//

import SwiftUI

@main

struct ProfilesApp: App {

    // this is to allow pop to root for iOS version under 16

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
