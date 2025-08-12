import SwiftUI
import SwiftData

@Model
final class Interview {
    @Attribute(.unique) var id: String
    var date: Date
    var notes: String
    
    init() {
        self.id = UUID().uuidString
        self.date = Date()
        self.notes = ""
    }
    
    convenience init(date: Date) {
        self.init()
        self.date = date
    }
}
