//
//  DueyNotification.swift
//
//

import Foundation

public struct DueyNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .duey }

    public init() { }
}

