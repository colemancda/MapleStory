//
//  PacketOpcode.swift
//  
//
//  Created by Alsey Coleman Miller on 12/4/22.
//

import Foundation

/// MapleStory Opcode
public protocol MapleStoryOpcode: RawRepresentable, Equatable, Hashable, Codable, Sendable where RawValue: BinaryInteger {
    
    init?(rawValue: RawValue)
    
    init?(data: Data)
    
    var data: Data { get }
}

extension MapleStoryOpcode where RawValue == UInt8 {
    
    public init?(data: Data) {
        guard data.count >= 1 else {
            return nil
        }
        self.init(rawValue: data[0])
    }
    
    public var data: Data {
        Data([rawValue])
    }
}

extension MapleStoryOpcode where RawValue == UInt16 {
    
    public init?(data: Data) {
        guard data.count >= 2 else {
            return nil
        }
        self.init(rawValue: UInt16(littleEndian: UInt16(bytes: (data[0], data[1]))))
    }
    
    public var data: Data {
        let bytes = self.rawValue.littleEndian.bytes
        return Data([bytes.0, bytes.1])
    }
}
