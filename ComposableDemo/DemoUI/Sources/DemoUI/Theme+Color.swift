import DemoModels
import SwiftUI

extension Theme {

    var accentColor: Color {
        switch self {
        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow:
            return .black
        case .indigo, .magenta, .navy, .oxblood, .purple:
            return .white
        }
    }

    var mainColor: Color {
        Color("\(rawValue)Theme", bundle: .module)
    }

    var name: String {
        rawValue.capitalized
    }
}
