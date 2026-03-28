//
//  DistributeAPRequest.swift
//

import Foundation

/// Client request to spend an AP point on a stat.
/// Stat values: STR=64, DEX=128, INT=256, LUK=512, HP=2048, MP=8192
public struct DistributeAPRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .distributeAP }

    internal let value0: UInt32

    /// Stat to increase (maps to `MapleStat` raw value)
    public let stat: UInt32
}
