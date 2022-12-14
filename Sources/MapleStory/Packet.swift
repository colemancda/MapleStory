//
//  Packet.swift
//  
//
//  Created by Alsey Coleman Miller on 12/13/22.
//

import Foundation

public struct Packet {
    
    public internal(set) var data: Data
    
    internal init(_ data: Data) {
        self.data = data
    }
    
    public init?(data: Data) {
        // TODO: Data length verification
        self.data = data
    }
    
    public init(opcode: Opcode) {
        self.data = Data()
    }
}

public extension Packet {
    
    var opcode: Opcode {
        get { Opcode(rawValue: UInt16(littleEndian: UInt16(bytes: (data[0], data[1])))) }
        set {
            let bytes = newValue.rawValue.littleEndian.bytes
            data[0] = bytes.0
            data[1] = bytes.1
        }
    }
}

// MARK: - CustomStringConvertible
/*
extension Packet: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        "Packet(opcode: \(opcode))"
    }
    
    public var debugDescription: String {
        description
    }
}
*/
// MARK: - Supporting Types

/// MapleStory Packet Parameters protocol
public protocol MapleStoryPacket {
    
    /// MapleStory command type
    static var opcode: Opcode { get }
}

internal extension MapleStoryPacket where Self: Decodable {
    
    init(packet: Packet, decoder: MapleStoryDecoder = MapleStoryDecoder()) throws {
        self = try decoder.decode(Self.self, from: packet)
    }
}
