//
//  DenyPartyRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct DenyPartyRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .denyPartyRequest }

    internal let value0: UInt8

    public let from: String

    public let to: String
}
