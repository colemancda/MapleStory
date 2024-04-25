//
//  Packet.swift
//  
//
//  Created by Alsey Coleman Miller on 12/13/22.
//

import Foundation

/// MapleStory Generic Packet
public struct Packet: Equatable, Hashable {
    
    public internal(set) var data: Data
    
    internal init(_ data: Data) {
        self.data = data
        assert(data.count >= Packet.minSize)
    }
    
    public init?(data: Data) {
        // validate size
        guard data.count >= Packet.minSize else {
            return nil
        }
        self.data = data
    }
    
    public init(opcode: Opcode, parameters: Data = Data()) {
        let length = Packet.minSize + parameters.count
        var data = Data(count: Packet.minSize)
        data.reserveCapacity(length)
        data += parameters
        assert(data.count == length)
        self.init(data)
        // set header bytes
        self.opcode = opcode
        assert(self.opcode == opcode)
    }
}

public extension Packet {
    
    static var minSize: Int { 2 }
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
    
    /// Packet parameters
    var parameters: Data {
        withUnsafeParameters { Data($0) }
    }
    
    var parametersSize: Int {
        data.count - Self.minSize
    }
    
    func withUnsafeParameters<ResultType>(_ body: ((UnsafeRawBufferPointer) throws -> ResultType)) rethrows -> ResultType {
        return try data.withUnsafeBytes { pointer in
            let parametersPointer = pointer.count > Packet.minSize ? pointer.baseAddress?.advanced(by: Packet.minSize) : nil
            return try body(UnsafeRawBufferPointer(start: parametersPointer, count: parametersSize))
        }
    }
}

// MARK: - CustomStringConvertible

extension Packet: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        "Packet(opcode: \(opcode), parameters: \(parametersSize) bytes)"
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - Supporting Types

/// MapleStory Packet Parameters protocol
public protocol MapleStoryPacket {
    
    /// MapleStory command type
    static var opcode: Opcode { get }
}

internal extension Packet {
    
    init<T>(_ packet: T, encoder: MapleStoryEncoder = MapleStoryEncoder()) throws where T: MapleStoryPacket, T: Encodable {
        self = try encoder.encodePacket(packet)
    }
}

internal extension MapleStoryPacket where Self: Decodable {
    
    init(packet: Packet, decoder: MapleStoryDecoder = MapleStoryDecoder()) throws {
        self = try decoder.decode(Self.self, from: packet)
    }
}
