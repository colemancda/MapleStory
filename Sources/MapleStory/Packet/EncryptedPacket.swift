//
//  EncryptedPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation

/// Encrypted Packet
public struct EncryptedPacket: Equatable, Hashable {
    
    public internal(set) var data: Data
    
    internal init(_ data: Data) {
        self.data = data
        assert(data.count >= Self.minSize)
    }
    
    public init?(data: Data) {
        // validate size
        guard data.count >= Self.minSize else {
            return nil
        }
        self.data = data
    }
}

public extension Packet {
    
    typealias Encrypted = EncryptedPacket
}

public extension EncryptedPacket {
    
    static var minSize: Int { 4 }
    
    var length: Int {
        Self.length(header)
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
            let parametersPointer = pointer.count > Self.minSize ? pointer.baseAddress?.advanced(by: Self.minSize) : nil
            return try body(UnsafeRawBufferPointer(start: parametersPointer, count: parametersSize))
        }
    }
}

// MARK: - CustomStringConvertible

extension EncryptedPacket: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        "EncryptedPacket(data: \(data.count) bytes)"
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - ExpressibleByArrayLiteral

extension EncryptedPacket: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: UInt8...) {
        self.init(Data(elements))
    }
}
