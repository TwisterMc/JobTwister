//
//  JobTwisterApp.swift
//  JobTwister
//
//  Created by Thomas McMahon on 6/25/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct JobTwisterApp: App {
    @State private var csvOperation: CSVOperation?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(item: $csvOperation) { operation in
                    CSVHandlerView(operation: operation)
                        .frame(minWidth: 300, minHeight: 150)
                }
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
            
            CommandGroup(after: .newItem) {
                Divider()
                Button("Import Jobs from CSV...") {
                    csvOperation = .import
                }
                Button("Export Jobs to CSV...") {
                    csvOperation = .export
                }
            }
        }
    }
}
