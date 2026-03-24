//
//  PetChatRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct PetChatRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .petChat }

    public let petID: UInt32

    internal let value0: UInt32

    internal let value1: UInt16

    public let message: String
}
