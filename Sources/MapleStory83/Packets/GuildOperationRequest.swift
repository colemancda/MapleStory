//
//  GuildOperationRequest.swift
//

import Foundation

public struct GuildOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .guildOperation }

    public let type: UInt8

    public let guildName: String?
    public let guildID: GuildID?
    public let characterID: Character.ID?
    public let characterName: String?
    public let rank: UInt8?
}

extension GuildOperationRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.type = try container.decode(UInt8.self)
        switch type {
        case 0x02:
            self.guildName = container.remainingBytes > 0 ? try container.decode(String.self) : nil
            self.guildID = nil
            self.characterID = nil
            self.characterName = nil
            self.rank = nil
        case 0x05:
            self.guildName = nil
            self.guildID = nil
            self.characterID = nil
            self.characterName = container.remainingBytes > 0 ? try container.decode(String.self) : nil
            self.rank = nil
        case 0x06:
            self.guildName = nil
            self.guildID = container.remainingBytes >= 4 ? try container.decode(GuildID.self) : nil
            self.characterID = container.remainingBytes >= 4 ? try container.decode(Character.ID.self) : nil
            self.characterName = nil
            self.rank = nil
        case 0x07, 0x08:
            self.guildName = nil
            self.guildID = nil
            self.characterID = container.remainingBytes >= 4 ? try container.decode(Character.ID.self) : nil
            self.characterName = container.remainingBytes > 0 ? try container.decode(String.self) : nil
            self.rank = nil
        case 0x0E:
            self.guildName = nil
            self.guildID = nil
            self.characterID = container.remainingBytes >= 4 ? try container.decode(Character.ID.self) : nil
            self.characterName = nil
            self.rank = container.remainingBytes >= 1 ? try container.decode(UInt8.self) : nil
        default:
            self.guildName = nil
            self.guildID = nil
            self.characterID = nil
            self.characterName = nil
            self.rank = nil
        }
    }
}
