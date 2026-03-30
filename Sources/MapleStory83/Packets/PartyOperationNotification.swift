//
//  PartyOperationNotification.swift
//

import Foundation
import MapleStory

/// Response to party operations.
public struct PartyOperationNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .partyOperation }

    public let operation: PartyOperation
    public let partyID: PartyID?
    public let members: [PartyMember]

    public init(operation: PartyOperation, partyID: PartyID? = nil, members: [PartyMember] = []) {
        self.operation = operation
        self.partyID = partyID
        self.members = members
    }

    public enum PartyOperation: UInt8, Codable, Equatable, Hashable, Sendable {
        case create     = 0x01
        case leave      = 0x02
        case accept     = 0x03
        case invite     = 0x04
        case expel      = 0x05
        case disband    = 0x06
        case passLeader = 0x07
    }
}

extension PartyOperationNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(operation.rawValue)
        if let partyID {
            try container.encode(partyID, isLittleEndian: true)
        }
        // Character index (UInt32) for each member slot — using 0 as placeholder
        // since PartyMember only carries Character.ID (UUID) not the numeric index.
        for _ in 0 ..< 6 {
            try container.encode(UInt32(0), isLittleEndian: true)
        }
        // Channel for each member slot
        for member in members {
            try container.encode(Int32(member.channel), isLittleEndian: true)
        }
        for _ in members.count ..< 6 {
            try container.encode(Int32(0), isLittleEndian: true)
        }
        // Map for each member slot
        for member in members {
            try container.encode(member.map.rawValue, isLittleEndian: true)
        }
        for _ in members.count ..< 6 {
            try container.encode(UInt32(0), isLittleEndian: true)
        }
        // Job and level for each member slot
        for member in members {
            try container.encode(member.job.rawValue, isLittleEndian: true)
            try container.encode(member.level, isLittleEndian: true)
        }
        for _ in members.count ..< 6 {
            try container.encode(UInt32(0), isLittleEndian: true)
            try container.encode(UInt16(0), isLittleEndian: true)
        }
    }
}
