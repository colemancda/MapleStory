//
//  UseDoorRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct UseDoorRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useDoor }

    public let objectID: UInt32

    /// 0 = town → field, 1 = field → town
    public let mode: UInt8
}
