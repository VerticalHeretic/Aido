//
//  OllamaProvider.swift
//  Aido
//
//  Created by Łukasz Stachnik on 19/01/2024.
//

import Alamofire
import Foundation

struct GenerateResponse: Codable {
    let model, createdAt, response: String
    let done: Bool

    enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case response, done
    }
}

struct GenerateRequest: Codable {
    let model: String
    let prompt: String
}

protocol ModelProvider {
    func generate(prompt: String, responseHandler: @escaping (String) -> ())
}

final class OllamaProvider: ModelProvider {

    func generate(prompt: String, responseHandler: @escaping (String) -> ()) {
        let request = GenerateRequest(model: "mistral", prompt: prompt)
        try! print(request.jsonPrettyPrinted())

        AF
            .streamRequest("http://localhost:11434/api/generate", method: .post, parameters: request, encoder: JSONParameterEncoder.prettyPrinted, automaticallyCancelOnStreamError: false)
            .responseStreamDecodable(of: GenerateResponse.self) { stream in
                switch stream.event {
                case let .stream(result):
                    switch result {
                    case let .success(value):
                        print(value)
                        responseHandler(value.response)
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
