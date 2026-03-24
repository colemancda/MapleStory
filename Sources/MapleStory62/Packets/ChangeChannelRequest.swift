//
//  ChangeChannelRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct ChangeChannelRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .changeChannel }

    /// 0-indexed channel number
    public let channel: UInt8
}
