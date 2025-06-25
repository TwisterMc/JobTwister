//
//  JobTwisterApp.swift
//  JobTwister
//
//  Created by Thomas McMahon on 6/25/25.
//

import SwiftUI
import SwiftData

@main
struct JobTwisterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Job.self)
        .commands {
            CommandGroup(replacing: .help) {
                Button("JobTwister Help") {
                    if let url = URL(string: "https://github.com/TwisterMc/JobTwister") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
}
