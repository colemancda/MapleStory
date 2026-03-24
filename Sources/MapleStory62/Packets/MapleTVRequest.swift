//
//  MapleTVRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct MapleTVRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .mapleTV }

    public let message: String

    internal let value0: UInt32

    internal let value1: UInt32
}
