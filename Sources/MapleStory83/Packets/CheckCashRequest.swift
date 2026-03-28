//
//  CheckCashRequest.swift
//

import Foundation

public struct CheckCashRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .checkCash }

    public init() { }
}
