//
//  HelloPacket.swift
//
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

/// MapleStory v83 Hello packet
///
/// This is the first packet sent by the server when a client connects.
public struct HelloPacket: Codable, Equatable, Hashable, Sendable {
    
    public let opcode: UInt16
    
    public let version: Version
    
    internal let value0: UInt16
    
    internal let value1: UInt8
        
    public var recieveNonce: Nonce
    
    public var sendNonce: Nonce
    
    public var region: Region
    
    public init(
        recieveNonce: Nonce,
        sendNonce: Nonce,
        region: Region = .global
    ) {
        self.opcode = 0x0E
        self.version = .v83
        self.recieveNonce = recieveNonce
        self.sendNonce = sendNonce
        self.region = region
        self.value0 = 1
        self.value1 = 49
    }
}
