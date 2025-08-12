import SwiftUI
import AppKit

enum AppTheme: String {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var appearance: NSAppearance? {
        switch self {
        case .system:
            return nil
        case .light:
            return NSAppearance(named: .aqua)
        case .dark:
            return NSAppearance(named: .darkAqua)
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .system {
        didSet {
            NSApp.appearance = currentTheme.appearance
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "AppTheme")
        }
    }
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "AppTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
            NSApp.appearance = theme.appearance
        }
    }
}
