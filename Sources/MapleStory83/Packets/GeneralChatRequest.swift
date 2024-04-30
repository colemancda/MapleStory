//
//  GeneralChatRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct GeneralChatRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x2E }
    
    public let message: String
    
    public let show: Bool
}
