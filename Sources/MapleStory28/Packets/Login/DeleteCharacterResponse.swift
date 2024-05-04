//
//  DeleteCharacterResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public struct DeleteCharacterResponse: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .deleteCharacterResponse }
    
    public let character: Character.Index
    
    internal let status: UInt8
    
    public init(
        character: Character.Index,
        error: DeleteCharacterResponse.Error? = nil
    ) {
        self.character = character
        self.status = error?.rawValue ?? 0x00
    }
}

public extension DeleteCharacterResponse {
    
    enum Error: UInt8, Codable, CaseIterable, Sendable, Swift.Error {
        
        case serverLoadError        = 0x0A
        case invalidDateOfBirth     = 0x12
    }
}
