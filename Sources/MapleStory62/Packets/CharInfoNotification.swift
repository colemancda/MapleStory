//
//  CharInfoNotification.swift
//
//

import Foundation

public struct CharInfoNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .charInfo }

    public init() { }
}

