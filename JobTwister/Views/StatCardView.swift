import SwiftUI

struct StatCardView: View {
    let value: Int
    let label: String
    let systemImage: String
    let color: Color
    
    init(value: Int, label: String, systemImage: String, color: Color) {
        self.value = value
        self.label = label
        self.systemImage = systemImage
        self.color = color
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text("\(value)")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
