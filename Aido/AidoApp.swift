//
//  AidoApp.swift
//  Aido
//
//  Created by Łukasz Stachnik on 18/01/2024.
//

import SwiftUI

@main
struct AidoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Todo.self])
    }
}
