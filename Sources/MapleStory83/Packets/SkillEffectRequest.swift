//
//  SkillEffectRequest.swift
//

import Foundation

public struct SkillEffectRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .skillEffect }

    public let skillID: UInt32

    public let level: UInt8

    public let flags: UInt8

    public let speed: UInt8
}
