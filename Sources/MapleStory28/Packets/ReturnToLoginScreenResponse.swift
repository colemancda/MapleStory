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
    
    public init() { }
}
