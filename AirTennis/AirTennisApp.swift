//
//  AirTennisApp.swift
//  AirTennis
//
//  Created by 谢增添 on 2025/11/4.
//

import SwiftUI
import SwiftData

@main
struct AirTennisApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SwingData.self,
            GoalSettings.self,
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
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
