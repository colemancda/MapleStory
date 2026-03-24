//
//  UpdateCharLookNotification.swift
//
//

import Foundation

public struct UpdateCharLookNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updateCharLook }

    public init() { }
}

