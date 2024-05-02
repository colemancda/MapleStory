//
//  CreateCharacterResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public enum CreateCharacterResponse: MapleStoryPacket, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .createCharacterResponse }
    
    public typealias Character = CharacterListResponse.Character
    
    case error
    case character(Character)
}

internal extension CreateCharacterResponse {
    
    var isError: Bool {
        switch self {
        case .error:
            return true
        case .character:
            return false
        }
    }
}

// MARK: - Codable

extension CreateCharacterResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case status
        case character
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isError = try container.decode(Bool.self, forKey: .status)
        if isError {
            self = .error
        } else {
            let character = try container.decode(Character.self, forKey: .character)
            self = .character(character)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let isError = self.isError
        try container.encode(isError, forKey: .status)
        switch self {
        case .error:
            break
        case .character(let character):
            try container.encode(character, forKey: .character)
        }
    }
}
