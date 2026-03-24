//
//  UseMountFoodRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct UseMountFoodRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useMountFood }

    internal let value0: UInt32

    public let slot: Int16

    public let itemID: UInt32
}
