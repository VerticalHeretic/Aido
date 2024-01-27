//
//  DebugDashboard.swift
//  Aido
//
//  Created by Łukasz Stachnik on 22/01/2024.
//

import KeychainAccess
import SwiftUI

struct DebugDashboard: View {

    @Observable
    class Model {
        let keychain = Keychain()

        var gptToken: String

        init() {
            let token = try? keychain.get("gptToken")

            if let token {
                gptToken = token
            } else {
                gptToken = ""
            }
        }
    }

    @State var model = Model()

    var body: some View {
        List {
            Section("LLM used for generations") {
                buildModelSelectionText(appConfig: .shared)

                Button("GPT 4.0") {
                    AppConfiguration.shared.modelProvider = GPTProvider(model: .gpt4)
                }

                Button("GPT 3.5") {
                    AppConfiguration.shared.modelProvider = GPTProvider(model: .gpt35)
                }

                Button("Mistral") {
                    AppConfiguration.shared.modelProvider = OllamaProvider()
                }
            }

            Section("Authentication") {
                SecureField("GPT Auth Token", text: $model.gptToken)
                    .onSubmit {
                        do {
                            try model.keychain.set(model.gptToken, key: "gptToken")
                        } catch {
                            print(error)
                        }
                    }
            }
        }
        .navigationTitle("Debug Dashboard")
    }

    @ViewBuilder func buildModelSelectionText(appConfig: AppConfiguration) -> some View {
        var modelName = ""

        if let gpt = AppConfiguration.shared.modelProvider as? GPTProvider {
            switch gpt.model {
            case .gpt4:
                modelName = "GPT-4.0"
            case .gpt35:
                modelName = "GPT-3.5"
            }
        }

        if let ollama = AppConfiguration.shared.modelProvider as? OllamaProvider {
            modelName = "Mistral"
        }

        return Text("Currently selected model for generation: **\(modelName)**")
    }
}

#Preview {
    DebugDashboard()
}
