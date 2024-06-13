import SwiftUI

public enum Theme: String, CaseIterable, Equatable, Identifiable, Codable {
    public var id: Self { self }

    case bubblegum
    case buttercup
    case indigo
    case lavender
    case magenta
    case navy
    case orange
    case oxblood
    case periwinkle
    case poppy
    case purple
    case seafoam
    case sky
    case tan
    case teal
    case yellow

    #warning("TODO: Move computed properties to UI target? 🤔")

    public var accentColor: Color {
        switch self {
        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow:
            return .black
        case .indigo, .magenta, .navy, .oxblood, .purple:
            return .white
        }
    }

    public var mainColor: Color { Color("\(rawValue)Theme") }
    public var name: String { rawValue.capitalized }
}
