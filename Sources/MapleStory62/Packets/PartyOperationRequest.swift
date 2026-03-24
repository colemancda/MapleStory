//
//  PartyOperationRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct PartyOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .partyOperation }

    public let operation: UInt8

    /// Used by operation `0x03` (accept invite).
    public let partyID: PartyID?

    /// Used by operation `0x04` (invite by character name).
    public let invitedName: String?

    /// Used by operations `0x05` (expel) and `0x06` (pass leader).
    public let targetCharacterID: Character.ID?
}

extension PartyOperationRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.operation = try container.decode(UInt8.self)
        switch operation {
        case 0x03:
            // Accept invite
            if container.remainingBytes >= 4 {
                self.partyID = try container.decode(PartyID.self)
            } else {
                self.partyID = nil
            }
            self.invitedName = nil
            self.targetCharacterID = nil
        case 0x04:
            // Invite
            self.partyID = nil
            if container.remainingBytes > 0 {
                self.invitedName = try container.decode(String.self)
            } else {
                self.invitedName = nil
            }
            self.targetCharacterID = nil
        case 0x05, 0x06:
            // Expel / pass leader
            self.partyID = nil
            self.invitedName = nil
            if container.remainingBytes >= 4 {
                self.targetCharacterID = try container.decode(Character.ID.self)
            } else {
                self.targetCharacterID = nil
            }
        default:
            self.partyID = nil
            self.invitedName = nil
            self.targetCharacterID = nil
        }
    }
}
