//
//  PartyOperationRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Party operation request from the client.
///
/// Each case represents a different party operation with its associated data:
/// - `create`: Create a new party
/// - `leave`: Leave current party
/// - `accept`: Accept a party invitation with the party ID
/// - `invite`: Invite a player by character name
/// - `expel`: Kick a member (leader only) by character ID
/// - `passLeader`: Transfer leadership to another member by character ID
/// - `disband`: Disband the party (leader only)
public enum PartyOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .partyOperation }

    /// Create a new party
    case create

    /// Leave current party
    case leave

    /// Accept a party invitation
    /// - Parameter partyID: The ID of the party to join
    case accept(partyID: PartyID)

    /// Invite a player to the party
    /// - Parameter characterName: The name of the character to invite
    case invite(characterName: String)

    /// Expel a member from the party (leader only)
    /// - Parameter characterID: The ID of the character to expel
    case expel(characterID: Character.ID)

    /// Transfer party leadership to another member
    /// - Parameter characterID: The ID of the new leader
    case passLeader(characterID: Character.ID)

    /// Disband the party (leader only)
    case disband
}

extension PartyOperationRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let operation = try container.decode(UInt8.self)
        switch operation {
        case 0x01:
            self = .create
        case 0x02:
            self = .leave
        case 0x03:
            // Accept invite
            let partyID = try container.decode(PartyID.self)
            self = .accept(partyID: partyID)
        case 0x04:
            // Invite
            let name = try container.decode(String.self)
            self = .invite(characterName: name)
        case 0x05:
            // Expel member
            let characterID = try container.decode(Character.ID.self)
            self = .expel(characterID: characterID)
        case 0x06:
            // Pass leadership
            let characterID = try container.decode(Character.ID.self)
            self = .passLeader(characterID: characterID)
        case 0x07:
            self = .disband
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown party operation: \(operation)"))
        }
    }
}
