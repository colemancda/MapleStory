//
//  MonsterCarnivalRequest.swift
//

import Foundation

public struct MonsterCarnivalRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .monsterCarnival }

    public init() { }
}
