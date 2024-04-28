//
//  HelloPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation

/// MapleStory v62 Hello packet
///
/// This is the first packet sent by the server when a client connects.
public struct HelloPacket: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x000D }
    
    public let version: Version
    
    internal let value0: UInt16
        
    public var recieveNonce: Nonce
    
    public var sendNonce: Nonce
    
    public var region: Region
    
    public init(
        recieveNonce: Nonce,
        sendNonce: Nonce,
        region: Region = .global
    ) {
        self.version = .v62
        self.recieveNonce = recieveNonce
        self.sendNonce = sendNonce
        self.region = region
        self.value0 = 0x0000
    }
}
