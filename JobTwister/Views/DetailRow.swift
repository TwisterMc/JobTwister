import SwiftUI

struct DetailRow<Content: View>: View {
    let title: String
    let value: String
    var content: (() -> Content)?
    
    init(title: String, value: String, content: (() -> Content)? = nil) {
        self.title = title
        self.value = value
        self.content = content
    }
    
    init(title: String, value: String) where Content == Never {
        self.title = title
        self.value = value
        self.content = nil
    }
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
                .frame(width: 120, alignment: .leading)
            if let content = content {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(value)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 4)
    }
}