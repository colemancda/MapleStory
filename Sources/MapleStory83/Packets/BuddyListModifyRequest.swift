//
//  BuddyListModifyRequest.swift
//

import Foundation

/// Buddy list modification request packet.
public enum BuddyListModifyRequest: Equatable, Hashable, Sendable {

    case add(name: String)
    case accept(characterID: UInt32)
    case remove(characterID: UInt32)
}

extension BuddyListModifyRequest: MapleStoryPacket {

    public static var opcode: ClientOpcode { .buddylistModify }
}

internal extension BuddyListModifyRequest {

    enum Mode: UInt8, Codable {
        case add = 1
        case accept = 2
        case remove = 3
    }
}

extension BuddyListModifyRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let mode = try container.decode(BuddyListModifyRequest.Mode.self)
        switch mode {
        case .add:
            let name = try container.decode(String.self)
            self = .add(name: name)
        case .accept:
            let characterID = try container.decode(UInt32.self)
            self = .accept(characterID: characterID)
        case .remove:
            let characterID = try container.decode(UInt32.self)
            self = .remove(characterID: characterID)
        }
    }
}
