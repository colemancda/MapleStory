//
//  ChangeMapRequest.swift
//

import Foundation

public struct ChangeMapRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .changeMap }

    /// 1 = death return, 2 = regular portal
    public let type: UInt8

    /// Target map ID (0x3B9AC9FF = none / use portal)
    public let targetMap: UInt32

    /// Portal name to warp through
    public let portalName: String

    internal let value0: UInt16

    internal let value1: UInt16
}
