//
//  HelloPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation

/// MapleStory Hello packet
///
/// This is the first packet sent by the server when a client connects.
public struct HelloPacket: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x000D }
    
    public var version: Version
        
    public var recieveNonce: Nonce
    
    public var sendNonce: Nonce
    
    public var region: Region
    
    public init(
        version: Version,
        recieveNonce: Nonce,
        sendNonce: Nonce,
        region: Region = .global
    ) {
        self.version = version
        self.recieveNonce = recieveNonce
        self.sendNonce = sendNonce
        self.region = region
    }
}
