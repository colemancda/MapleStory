//
//  CancelBuffRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct CancelBuffRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .cancelBuff }

    /// Skill / buff ID to cancel
    public let skillID: UInt32
}
