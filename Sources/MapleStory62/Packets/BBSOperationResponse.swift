//
//  BBSOperationResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct BBSOperationResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ServerOpcode { .bbsOperation }
    
}
