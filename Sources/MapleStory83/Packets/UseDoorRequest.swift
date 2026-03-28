//
//  UseDoorRequest.swift
//

import Foundation

public struct UseDoorRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useDoor }

    public let objectID: UInt32

    /// 0 = town → field, 1 = field → town
    public let mode: UInt8
}
