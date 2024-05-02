//
//  Packet.swift
//  
//
//  Created by Alsey Coleman Miller on 12/13/22.
//

import Foundation

/// MapleStory Generic Packet
public struct Packet<Opcode: MapleStoryOpcode>: Equatable, Hashable, Sendable {
    
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
        // validate opcode
        guard readOpcode() != nil else {
            return nil
        }
    }
    
    public init(opcode: Opcode, parameters: Data = Data()) {
        let length = Packet.minSize + parameters.count
        var data = opcode.data
        data.reserveCapacity(length)
        data += parameters
        self.init(data)
        // assertions
        assert(data.count == length)
        assert(readOpcode() == opcode)
    }
}

public extension Packet {
    
    static var minSize: Int { MemoryLayout<Opcode.RawValue>.size }
}

internal extension Packet {
    
    func readOpcode() -> Opcode? {
        Opcode(data: data.prefix(MemoryLayout<Opcode.RawValue>.size))
    }
}

public extension Packet {
    
    var opcode: Opcode {
        guard let opcode = readOpcode() else {
            fatalError("Invalid opcode bytes")
        }
        return opcode
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

// MARK: - ExpressibleByArrayLiteral

extension Packet: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: UInt8...) {
        self.init(Data(elements))
    }
}

// MARK: - Supporting Types

/// MapleStory Packet Parameters protocol
public protocol MapleStoryPacket {
    
    associatedtype Opcode: MapleStoryOpcode
    
    /// MapleStory packet opcode.
    static var opcode: Opcode { get }
}

internal extension Packet {
    
    init<T>(
        _ packet: T,
        encoder: MapleStoryEncoder = MapleStoryEncoder()
    ) throws where T: MapleStoryPacket, T: Encodable, T.Opcode == Opcode {
        self = try encoder.encodePacket(packet)
    }
}

internal extension MapleStoryPacket where Self: Decodable {
    
    init(packet: Packet<Opcode>, decoder: MapleStoryDecoder = MapleStoryDecoder()) throws {
        self = try decoder.decode(Self.self, from: packet)
    }
}
