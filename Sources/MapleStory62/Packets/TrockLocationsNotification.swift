//
//  TrockLocationsNotification.swift
//
//

import Foundation

public struct TrockLocationsNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .trockLocations }

    public init() { }
}

