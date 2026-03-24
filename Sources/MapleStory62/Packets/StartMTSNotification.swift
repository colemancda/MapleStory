//
//  StartMTSNotification.swift
//
//

import Foundation

public struct StartMTSNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .startMTS }

    public init() { }
}

