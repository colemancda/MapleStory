//
//  CancelItemEffectRequest.swift
//

import Foundation

public struct CancelItemEffectRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .cancelItemEffect }

    public let skillID: UInt32
}
