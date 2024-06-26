//
//  PinOperationRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct PinOperationRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .afterLogin }
    
    public let value0: UInt8
    
    public let value1: UInt8?
    
    public let pinCode: String?
}

extension PinOperationRequest: MapleStoryDecodable {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        value0 = try container.decode(UInt8.self, forKey: CodingKeys.value0)
        value1 = (container.remainingBytes > 0) ? try container.decode(UInt8.self, forKey: CodingKeys.value1) : nil
        pinCode = (container.remainingBytes > 0) ? try container.decode(String.self, forKey: CodingKeys.pinCode) : nil
    }
}
