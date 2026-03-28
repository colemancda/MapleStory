//
//  GiveFameRequest.swift
//

import Foundation

public struct GiveFameRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .giveFame }

    /// Target character ID
    public let characterID: UInt32

    /// 0 = decrease fame, 1 = increase fame
    public let mode: UInt8
}
