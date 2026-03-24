//
//  UpdateSkillsNotification.swift
//
//

import Foundation

public struct UpdateSkillsNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updateSkills }

    public init() { }
}

