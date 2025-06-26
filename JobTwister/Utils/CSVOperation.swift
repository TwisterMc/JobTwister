import Foundation

public enum CSVOperation: String, Identifiable {
    case `import`
    case export
    
    public var id: String { rawValue }
}
