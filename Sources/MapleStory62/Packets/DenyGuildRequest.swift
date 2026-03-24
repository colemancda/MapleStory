//
//  DenyGuildRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct DenyGuildRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .denyGuildRequest }

    internal let value0: UInt8

    public let from: String
}
