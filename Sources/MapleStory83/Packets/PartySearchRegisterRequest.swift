//
//  PartySearchRegisterRequest.swift
//

import Foundation

public struct PartySearchRegisterRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .partySearchRegister }

    public init() { }
}
