//
//  AutoAggroRequest.swift
//

import Foundation

public struct AutoAggroRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .autoAggro }

    public let objectID: UInt32
}
