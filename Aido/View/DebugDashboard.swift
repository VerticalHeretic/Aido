//
//  DebugDashboard.swift
//  Aido
//
//  Created by Łukasz Stachnik on 22/01/2024.
//

import SwiftUI

struct DebugDashboard: View {

    var body: some View {
        List {
            Section("LLM used for generations") {
                Button("GPT 4.0") {}

                Button("GPT 3.5") {}

                Button("Mistral") {
                    AppConfiguration.shared.modelProvider = OllamaProvider()
                }
            }
        }
        .navigationTitle("Debug Dashboard")
    }
}

#Preview {
    DebugDashboard()
}
