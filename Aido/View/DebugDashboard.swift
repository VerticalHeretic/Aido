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
                Button("GPT 4.0") {
                    AppConfiguration.shared.modelProvider = GPTProvider()
                }

                Button("GPT 3.5") {}

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
}

#Preview {
    DebugDashboard()
}
