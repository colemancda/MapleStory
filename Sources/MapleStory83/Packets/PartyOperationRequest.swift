//
//  PartyOperationRequest.swift
//

import Foundation
import MapleStory

/// Party operation request from the client.
public enum PartyOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .partyOperation }

    case create
    case leave
    case accept(partyID: PartyID)
    case invite(characterName: String)
    case expel(characterID: Character.ID)
    case passLeader(characterID: Character.ID)
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
            let partyID = try container.decode(PartyID.self)
            self = .accept(partyID: partyID)
        case 0x04:
            let name = try container.decode(String.self)
            self = .invite(characterName: name)
        case 0x05:
            let characterID = try container.decode(Character.ID.self)
            self = .expel(characterID: characterID)
        case 0x06:
            let characterID = try container.decode(Character.ID.self)
            self = .passLeader(characterID: characterID)
        case 0x07:
            self = .disband
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown party operation: \(operation)"))
        }
    }
}
