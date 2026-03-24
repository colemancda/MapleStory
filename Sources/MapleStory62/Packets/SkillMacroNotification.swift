//
//  SkillMacroNotification.swift
//
//

import Foundation

public struct SkillMacroNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .skillMacro }

    public init() { }
}

