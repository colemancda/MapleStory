//
//  ShowForeignEffectNotification.swift
//
//

import Foundation

public struct ShowForeignEffectNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showForeignEffect }

    public init() { }
}

