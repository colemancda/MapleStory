//
//  UpdateCharBoxNotification.swift
//
//

import Foundation

public struct UpdateCharBoxNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updateCharBox }

    public init() { }
}

