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
    @StateObject private var themeManager = ThemeManager.shared
    
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
            
            CommandGroup(after: .sidebar) {
                Picker("Theme", selection: $themeManager.currentTheme) {
                    Text("System Theme")
                        .tag(AppTheme.system)
                        .keyboardShortcut("0", modifiers: [.command, .shift])
                        
                    Text("Light Theme")
                        .tag(AppTheme.light)
                        .keyboardShortcut("1", modifiers: [.command, .shift])
                        
                    Text("Dark Theme")
                        .tag(AppTheme.dark)
                        .keyboardShortcut("2", modifiers: [.command, .shift])
                }
            }
        }
    }
}
