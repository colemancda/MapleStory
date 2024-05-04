//
//  PinOperationResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public struct PinOperationResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ServerOpcode { .loginPinOperation }
    
    public let status: PinCodeStatus
    
    public init(status: PinCodeStatus) {
        self.status = status
    }
}
