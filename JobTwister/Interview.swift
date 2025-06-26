import Foundation
import SwiftData

@Model
class Interview {
    var date: Date
    var notes: String
    var round: Int
    
    init(date: Date = Date(), notes: String = "", round: Int = 1) {
        self.date = date
        self.notes = notes
        self.round = round
    }
}