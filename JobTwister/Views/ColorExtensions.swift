import SwiftUI

extension Color {
    static func workplaceTypeColor(_ type: WorkplaceType) -> Color {
        switch type {
        case .remote:
            return .blue
        case .hybrid:
            return .purple
        case .inOffice:
            return .orange
        }
    }
}