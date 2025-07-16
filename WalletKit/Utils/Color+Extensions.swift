

import SwiftUI

extension Color {
    static func fromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "green":
            return .green
        case "blue":
            return .blue
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "orange":
            return .orange
        case "red":
            return .red
        case "indigo":
            return .indigo
        case "gray":
            return .gray
        case "brown":
            return .brown
        default:
            return .primary
        }
    }
} 
