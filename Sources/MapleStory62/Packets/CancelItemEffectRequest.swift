//
//  CancelItemEffectRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct CancelItemEffectRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .cancelItemEffect }

    public let skillID: UInt32
}
