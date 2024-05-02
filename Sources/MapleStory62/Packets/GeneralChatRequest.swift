//
//  GeneralChatRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/23/22.
//

import Foundation

public struct GeneralChatRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ClientOpcode { .generalChat }
    
    public let message: String
    
    public let show: Bool
}
