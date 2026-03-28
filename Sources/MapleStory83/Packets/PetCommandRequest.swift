//
//  PetCommandRequest.swift
//

import Foundation

public struct PetCommandRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .petCommand }

    public let petID: UInt32

    internal let value0: UInt32

    internal let value1: UInt8

    public let command: UInt8
}
