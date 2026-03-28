//
//  PetChatRequest.swift
//

import Foundation

public struct PetChatRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .petChat }

    public let petID: UInt32

    internal let value0: UInt32

    internal let value1: UInt16

    public let message: String
}
