//
//  ComposableDemoApp.swift
//  ComposableDemo
//
//  Created by Adam Londa on 14.05.2024.
//

import ComposableArchitecture
import DemoReducers
import DemoUI
import SwiftUI

#warning("TODO: Implement speech recognition feature, when it's available in P3 tutorial 🎗️")

@main
struct ComposableDemoApp: App {

    @MainActor static let store = Store(initialState: AppFeatureReducer.State()) {
        AppFeatureReducer()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}

#if compiler(<6.0) || !hasFeature(InferSendableFromCaptures)
#warning("Remove this workaround when Swift 6 is available 🎗️")
// Related to Strict Concurrency warnings
extension KeyPath: @unchecked Sendable {}
#endif
