//
//  ReturnToLoginScreenResponse.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import MapleStory

public struct ReturnToLoginScreenResponse: MapleStoryPacket, Equatable, Hashable, Codable, Sendable {
    
    public static var opcode: ServerOpcode { .loginRestarter }
    
    internal let value0: UInt8
    
    public init() {
        self.value0 = 0x01
    }
}
