//
//  ShowEquipEffectNotification.swift
//
//

import Foundation

public struct ShowEquipEffectNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showEquipEffect }

    public init() { }
}

extension ShowEquipEffectNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws { }
}

