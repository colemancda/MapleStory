//
//  UseReturnScrollRequest.swift
//

import Foundation

public struct UseReturnScrollRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useReturnScroll }

    internal let value0: UInt32

    public let slot: Int16

    public let itemID: UInt32
}
