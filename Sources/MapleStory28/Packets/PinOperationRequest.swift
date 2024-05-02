//
//  PinOperationRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public struct PinOperationRequest: MapleStoryPacket, Decodable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .checkLogin }
    
    public let value0: UInt8
    
    public let value1: UInt8
    
    public let pinCode: String?
}

extension PinOperationRequest: MapleStoryDecodable {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        value0 = try container.decode(UInt8.self, forKey: CodingKeys.value0)
        value1 = try container.decode(UInt8.self, forKey: CodingKeys.value1)
        _ = try container.decode(Data.self, length: 6) // skip 6 bytes
        pinCode = (container.remainingBytes > 0) ? try container.decode(String.self, forKey: CodingKeys.pinCode) : nil
    }
}
