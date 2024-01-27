//
//  OllamaProvider.swift
//  Aido
//
//  Created by Łukasz Stachnik on 19/01/2024.
//

import Alamofire
import Foundation

struct GenerateResponse: Codable {
    let model, createdAt: String
    let message: ChatCompletionMessage
    let done: Bool

    enum CodingKeys: String, CodingKey {
        case model
        case message
        case createdAt = "created_at"
        case done
    }
}

struct GenerateRequest: Codable {
    let model: String
    let messages: [ChatCompletionMessage]
}

protocol TextToTextModelProvider {
    func generate(prompt: String, responseHandler: @escaping (String) -> ())
}

enum OllamaModel {

    enum TextToText: String {
        case mistral
        case llama2
        case llama2Uncensored = "llama2-uncensored"
    }
}

final class OllamaTextToTextProvider: TextToTextModelProvider {

    private(set) var model: OllamaModel.TextToText

    init(model: OllamaModel.TextToText = .mistral) {
        self.model = model
    }

    func generate(prompt: String, responseHandler: @escaping (String) -> ()) {
        let request = GenerateRequest(
            model: model.rawValue,
            messages: [
                .init(role: "system", content: """
You are a todo application assistant, you are creating a actionable checklists for the given todo. Those can be funny and even a little bit naughty. Keep them max 5 points and 250 words.
Desired format:
<dot_separated_list_of_action_points_without_whitespace_on_beggining_or_end>
"""),
                .init(role: "user", content: prompt)
            ])
        try! print(request.jsonPrettyPrinted())

        AF
            .streamRequest("http://localhost:11434/api/chat", method: .post, parameters: request, encoder: JSONParameterEncoder.prettyPrinted, automaticallyCancelOnStreamError: false)
            .responseStreamDecodable(of: GenerateResponse.self) { stream in
                switch stream.event {
                case let .stream(result):
                    switch result {
                    case let .success(value):
                        print(value)
                        responseHandler(value.message.content)
                    case let .failure(error):
                        print(error)
                    }
                case let .complete(completion):
                    print(completion)
                }
            }
    }
}

extension JSONEncoder {
    static let shared: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
}

extension Encodable {
    func dataPrettyPrinted() throws -> Data {
        try JSONEncoder.shared.encode(self)
    }

    func jsonPrettyPrinted() throws -> String {
        try String(data: dataPrettyPrinted(), encoding: .utf8) ?? ""
    }
}
