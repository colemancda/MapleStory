//
//  NPCActionResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public enum NPCActionResponse: MapleStoryPacket, Encodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0xC5 }
    
    /// Talk
    case talk(UInt32, UInt16)
    
    /// Move
    case move(Data)
}

// MARK: - MapleStoryDecoder

extension NPCActionResponse: MapleStoryEncodable {
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .talk(int, short):
            try container.encode(int)
            try container.encode(short)
        case let .move(data):
            try container.encode(data)
        }
    }
}
