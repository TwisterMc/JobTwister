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
    @State var selectedJob: Job?
        @State var showingAddJob: Bool = false // JobTwisterApp owns this state
    
    var body: some Scene {
        WindowGroup {
            ContentView(selectedJob: $selectedJob, showingAddJob: $showingAddJob)
                .sheet(item: $csvOperation) { operation in
                    CSVHandlerView(operation: operation)
                        .frame(minWidth: 300, minHeight: 150)
                }
        }
        .modelContainer(for: Job.self)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Job Application") {
                    selectedJob = nil
                    showingAddJob.toggle()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
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
