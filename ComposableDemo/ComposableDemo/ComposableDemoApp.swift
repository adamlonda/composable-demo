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

    @MainActor static let store = Store(initialState: SyncUpsList.State()) {
        SyncUpsList()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SyncUpsListView(store: Self.store)
            }
        }
    }
}
