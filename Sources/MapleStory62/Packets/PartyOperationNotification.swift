//
//  PartyOperationNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Response to party operations
public struct PartyOperationNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .partyOperation }

    /// Operation type
    public let operation: PartyOperation

    /// Party ID (nil if disbanded)
    public let partyID: PartyID?

    /// Party members
    public let members: [PartyMember]

    public init(
        operation: PartyOperation,
        partyID: PartyID? = nil,
        members: [PartyMember] = []
    ) {
        self.operation = operation
        self.partyID = partyID
        self.members = members
    }

    /// Party operation type
    public enum PartyOperation: UInt8, Codable, Equatable, Hashable, Sendable {
        case create = 0x01
        case leave = 0x02
        case accept = 0x03
        case invite = 0x04
        case expel = 0x05
        case disband = 0x06
        case passLeader = 0x07
    }
}
