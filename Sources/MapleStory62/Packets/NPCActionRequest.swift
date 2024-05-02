//
//  NPCActionRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public enum NPCActionRequest: MapleStoryPacket, Decodable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .npcAction }
    
    /// Talk
    case talk(UInt32, UInt16)
    
    /// Move
    case move(Data)
}

// MARK: - MapleStoryDecoder

extension NPCActionRequest: MapleStoryDecodable {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let length = container.remainingBytes
        if length == 6 {
            let value0 = try container.decode(UInt32.self)
            let value1 = try container.decode(UInt16.self)
            self = .talk(value0, value1)
        } else if length > 6 {
            let data = try container.decode(Data.self, length: length - 9)
            self = .move(data)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not enough bytes"))
        }
    }
}
