//
//  PetFoodRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct PetFoodRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .petFood }

    internal let value0: UInt32

    internal let value1: UInt16

    public let itemID: UInt32
}
