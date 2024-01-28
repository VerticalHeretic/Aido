//
//  GPTTextToImageProvider.swift
//  Aido
//
//  Created by Łukasz Stachnik on 28/01/2024.
//

import Alamofire
import Foundation
import KeychainAccess
import OSLog

enum ImageSize: String, Codable {
    case small = "256x256" // Dalle 2
    case medium = "512x512" // Dalle 2
    case large = "1024x1024" // Dalle 2 and 3
    case extraLarge = "1792x1024" // Dalle 3
}

struct ImageGenerateRequest: Codable {
    let model: String
    let prompt: String
    let numberOfImages: Int
    let responseFormat: String
    let size: ImageSize

    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case numberOfImages = "n"
        case responseFormat = "response_format"
        case size
    }
}

struct ImageGenerateResponse: Codable {
    let data: [ImageObject]
}

struct ImageObject: Codable {
//    let revisedPrompt: String
    let json: String

    enum CodingKeys: String, CodingKey {
//        case revisedPrompt = "revised_prompt"
        case json = "b64_json"
    }
}

final class GPTTextToImageProvider {

    private let keychain: Keychain
    private(set) var model: GPTModel.TextToImage

    init(keychain: Keychain = Keychain(), model: GPTModel.TextToImage = .dalle3) {
        self.keychain = keychain
        self.model = model
    }

    func generate(prompt: String) async -> Data? {
        let request = ImageGenerateRequest(
            model: model.rawValue,
            prompt: prompt,
            numberOfImages: 1,
            responseFormat: "b64_json",
            size: .large
        )

        guard let token = try? keychain.get("gptToken") else { return nil }

        let json = try? await AF
            .request(
                "https://api.openai.com/v1/images/generations",
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.prettyPrinted,
                headers: .init([.init(name: "Authorization", value: "Bearer \(token)")])
            )
            .responseString { response in
                Logger.general.info("\(response.value ?? "")")
            }
            .serializingDecodable(ImageGenerateResponse.self)
            .value
            .data
            .first?.json
        
        return Data(base64Encoded: json ?? "")
    }
}
