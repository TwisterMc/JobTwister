import SwiftUI

struct StatCardView: View {
    let value: Int
    let label: String
    let systemImage: String
    let color: Color
    
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
                .foregroundColor(.secondary)
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