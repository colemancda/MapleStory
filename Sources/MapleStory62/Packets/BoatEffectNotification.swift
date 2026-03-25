//
//  BoatEffectNotification.swift
//
//

import Foundation

public struct BoatEffectNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .boatEffect }

    public let effect: UInt16

    public init(effect: UInt16) {
        self.effect = effect
    }
}

extension BoatEffectNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(effect, isLittleEndian: true)
    }
}

