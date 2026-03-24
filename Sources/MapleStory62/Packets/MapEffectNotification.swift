//
//  MapEffectNotification.swift
//
//

import Foundation

public struct MapEffectNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .mapEffect }

    public init() { }
}

