//
//  PartySearchUpdateRequest.swift
//

import Foundation

public struct PartySearchUpdateRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .partySearchUpdate }

    public init() { }
}
