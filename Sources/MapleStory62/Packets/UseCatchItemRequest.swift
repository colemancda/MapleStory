//
//  UseCatchItemRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct UseCatchItemRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useCatchItem }

    internal let value0: UInt32

    public let slot: Int16

    public let itemID: UInt32

    public let monsterID: UInt32
}
