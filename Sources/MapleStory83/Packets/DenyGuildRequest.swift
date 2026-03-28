//
//  DenyGuildRequest.swift
//

import Foundation

public struct DenyGuildRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .denyGuildRequest }

    public let characterName: String
}
