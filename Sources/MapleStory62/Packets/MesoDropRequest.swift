//
//  MesoDropRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct MesoDropRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .mesoDrop }

    internal let value0: UInt32

    /// Amount of meso to drop
    public let amount: UInt32
}
