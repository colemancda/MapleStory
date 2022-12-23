//
//  ServerMessageNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct ServerMessageNotification: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x41 }
    
    public let type: ServerMessageType
    
    //public let isServer: Bool?
    
    public let message: String
    
    //public let channel: UInt8?
    
    //public let megaEarphone: Bool?
}
