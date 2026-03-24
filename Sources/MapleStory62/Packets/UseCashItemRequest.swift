//
//  UseCashItemRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct UseCashItemRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useCashItem }

    public let mode: UInt8

    internal let value0: UInt8

    public let itemID: UInt32
}
