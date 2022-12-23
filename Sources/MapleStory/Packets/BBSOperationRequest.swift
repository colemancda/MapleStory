//
//  BBSOperationRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public enum BBSOperationRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x86 }
    
    case new(notice: Bool, title: String, body: String, icon: UInt32)
    case edit(id: UInt32, notice: Bool, title: String, message: String, icon: UInt32)
    case delete(id: UInt32)
    case list(start: UInt32)
    case listReply(id: UInt32)
    case reply(id: UInt32, body: String)
    case deleteReply(id: UInt32, reply: UInt32)
}
