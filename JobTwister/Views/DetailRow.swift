import SwiftUI

struct DetailRow<Content: View>: View {
    let title: String
    let value: String
    var content: (() -> Content)?
    var isBold: Bool = true
    
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
    
    var iconName: String?
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .foregroundColor(.secondary)
                }
                Text(title)
                    .fontWeight(isBold ? .bold : .regular)
            }
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
    
    func icon(_ name: String) -> Self {
        var view = self
        view.iconName = name
        return view
    }
    
    func bold(_ isBold: Bool) -> Self {
        var view = self
        view.isBold = isBold
        return view
    }
}