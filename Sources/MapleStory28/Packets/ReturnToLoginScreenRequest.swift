//
//  ReturnToLoginScreenRequest.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import MapleStory

public struct ReturnToLoginScreenRequest: MapleStoryPacket, Equatable, Hashable, Codable, Sendable {
    
    public static var opcode: ClientOpcode { .returnToLoginScreen }
    
    public init() { }
}
