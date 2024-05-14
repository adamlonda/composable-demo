//
//  ContentView.swift
//  ComposableDemo
//
//  Created by Adam Londa on 14.05.2024.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
