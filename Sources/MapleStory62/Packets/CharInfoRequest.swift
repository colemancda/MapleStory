//
//  CharInfoRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct CharInfoRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .charInfoRequest }

    internal let value0: UInt16

    internal let value1: UInt16

    /// Character ID to look up
    public let characterID: UInt32
}
