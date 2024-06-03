//
//  ComposableDemoApp.swift
//  ComposableDemo
//
//  Created by Adam Londa on 14.05.2024.
//

import ComposableArchitecture
import SwiftUI

@main
struct ComposableDemoApp: App {

    @MainActor static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
