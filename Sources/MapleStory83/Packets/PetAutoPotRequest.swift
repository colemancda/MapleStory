//
//  PetAutoPotRequest.swift
//

import Foundation

public struct PetAutoPotRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .petAutoPot }

    public let type: UInt8

    internal let value0: UInt64

    internal let value1: UInt32

    public let slot: UInt8

    internal let value2: UInt8

    public let itemID: UInt32
}
