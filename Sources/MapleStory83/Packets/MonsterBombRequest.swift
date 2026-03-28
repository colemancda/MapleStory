//
//  MonsterBombRequest.swift
//

import Foundation

public struct MonsterBombRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .monsterBomb }

    public let objectID: UInt32
}
