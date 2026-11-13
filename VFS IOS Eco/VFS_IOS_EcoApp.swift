//
//  VFS_IOS_EcoApp.swift
//  VFS IOS Eco
//
//  Created by Gavin Etmanski on 2026-11-13.
//

import SwiftUI
import SwiftData

@main
struct VFS_IOS_EcoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
