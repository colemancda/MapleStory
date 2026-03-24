//
//  RelogResponse.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation
import MapleStory

public struct RelogResponse: MapleStoryPacket, Equatable, Hashable, Codable, Sendable {

    public static var opcode: ServerOpcode { .relogResponse }

    internal let value0: UInt8

    public init() {
        self.value0 = 0x01
    }
}
