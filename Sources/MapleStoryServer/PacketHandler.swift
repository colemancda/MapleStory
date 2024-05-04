//
//  PacketHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import MapleStory
import CoreModel

/// MapleStory Server Event Handler
public protocol ServerHandler {
    
    associatedtype ClientOpcode: MapleStoryOpcode
    
    associatedtype ServerOpcode: MapleStoryOpcode
    
    associatedtype Socket: MapleStorySocket
    
    associatedtype Database: CoreModel.ModelStorage
    
    func didConnect(
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async
    
    func didDisconnect(address: MapleStoryAddress) async
}

/// MapleStory Server Packet Handler
public protocol PacketHandler {
    
    associatedtype ServerOpcode: MapleStoryOpcode
    
    associatedtype Packet: MapleStoryPacket & Decodable
    
    func handle<Socket: MapleStorySocket, Storage: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Storage, Packet.Opcode, ServerOpcode>.Connection
    ) async throws
}
