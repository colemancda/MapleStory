//
//  PartySearchStartRequest.swift
//

import Foundation

public struct PartySearchStartRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .partySearchStart }

    public init() { }
}
