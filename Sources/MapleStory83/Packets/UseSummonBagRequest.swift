//
//  UseSummonBagRequest.swift
//

import Foundation

public struct UseSummonBagRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useSummonBag }

    internal let value0: UInt32

    public let slot: Int16

    public let itemID: UInt32
}
