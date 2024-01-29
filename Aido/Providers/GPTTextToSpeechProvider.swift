//
//  GPTTextToSpeechProvider.swift
//  Aido
//
//  Created by Łukasz Stachnik on 28/01/2024.
//

import Alamofire
import AVFoundation
import Foundation
import KeychainAccess
import OSLog

enum VoiceType: String, Codable {
    case fable
    case alloy
    case onyx
    case echo
}

struct SpeechGenerateRequest: Codable {
    let model: String
    let input: String
    let voice: VoiceType

    enum CodingKeys: String, CodingKey {
        case model
        case input
        case voice
    }
}

final class GPTTextToSpeechProvider {

    private let keychain: Keychain
    private(set) var model: GPTModel.TextToSpeech

    init(keychain: Keychain = Keychain(), model: GPTModel.TextToSpeech = .tss1hd) {
        self.keychain = keychain
        self.model = model
    }

    func generate(text: String, voiceType: VoiceType = .fable) async -> Data? {
        let request = SpeechGenerateRequest(
            model: model.rawValue,
            input: text,
            voice: voiceType
        )

        guard let token = try? keychain.get("gptToken") else { return nil }

        return try? await AF
            .request(
                "https://api.openai.com/v1/audio/speech",
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.prettyPrinted,
                headers: .init([.init(name: "Authorization", value: "Bearer \(token)")])
            )
            .responseString { response in
                Logger.general.info("\(response.value ?? "")")
            }
            .serializingData()
            .value
    }
}

final class AudioPlayerManager {
    private var audioPlayer: AVAudioPlayer?

    func stopAudio() {
        audioPlayer?.stop()
    }

    func playAudio(from base64Data: Data?) {
        guard let base64Data else {
            print("Error: Audio data is invalid")
            return
        }

        do {
            // Initialize the audio player and play
            audioPlayer = try AVAudioPlayer(data: base64Data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
