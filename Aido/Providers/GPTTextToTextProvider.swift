//
//  GPTProvider.swift
//  Aido
//
//  Created by Łukasz Stachnik on 23/01/2024.
//

import Alamofire
import Foundation
import KeychainAccess

struct ChatCompletionResponse: Codable {
    let id: String
    let choices: [Choice]
}

struct Choice: Codable {
    let index: Int
    let delta: Delta
}

// MARK: - Delta
struct Delta: Codable {
    let content: String
}

struct ChatCompletionMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionRequest: Codable {
    let model: String
    let stream: Bool?
    let messages: [ChatCompletionMessage]
}

enum GPTModel {

    enum TextToText: String {
        case gpt4 = "gpt-4"
        case gpt35 = "gpt-3.5-turbo"
    }

    enum TextToImage: String {
        case dalle3 = "dall-e-3"
    }
}

final class GPTTextToTextProvider: TextToTextModelProvider {

    private let keychain: Keychain
    private(set) var model: GPTModel.TextToText

    init(keychain: Keychain = Keychain(), model: GPTModel.TextToText = .gpt35) {
        self.keychain = keychain
        self.model = model
    }

    func generate(prompt: String, responseHandler: @escaping (String) -> ()) {
        let request = ChatCompletionRequest(
            model: model.rawValue,
            stream: true,
            messages: [
                .init(role: "system", content: "You are a todo application assistant, you are creating a actionable checklists for the given todo. Those can be funny and even a little bit naughty. Keep them max 5 points."),
                .init(role: "user", content: prompt)
            ])
        try! print(request.jsonPrettyPrinted())

        guard let token = try? keychain.get("gptToken") else { return }

        AF
            .streamRequest("https://api.openai.com/v1/chat/completions",
                           method: .post,
                           parameters: request,
                           encoder: JSONParameterEncoder.prettyPrinted,
                           headers: .init([.init(name: "Authorization", value: "Bearer \(token)")]),
                           automaticallyCancelOnStreamError: false)
            .responseStreamString { [weak self] stream in
                guard let self else { return }

                switch stream.event {
                case let .stream(result):
                    switch result {
                    case let .success(value):
                        let response = self.parseResponseData(value).flatMap { $0.choices }.map { $0.delta.content }.joined()
                        responseHandler(response)
                    case let .failure(error):
                        print(error)
                    }
                case let .complete(completion):
                    print(completion)
                }
            }
    }

    private func parseResponseData(_ data: String) -> [ChatCompletionResponse] {
        let responseString = data
            .split(separator: "data:")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let jsonDecoder = JSONDecoder()

        return responseString.compactMap { jsonString in
            guard let jsonData = jsonString.data(using: .utf8), let streamResponse = try? jsonDecoder.decode(ChatCompletionResponse.self, from: jsonData) else { return nil }
            return streamResponse
        }
    }
}
