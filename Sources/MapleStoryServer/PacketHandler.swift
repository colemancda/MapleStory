//
//  PacketHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import MapleStory
import CoreModel

public protocol ServerHandler {
    
    func didConnect<Socket: MapleStorySocket, Storage: ModelStorage>(connection: MapleStoryServer<Socket, Storage>.Connection)
    
    func didDisconnect(address: MapleStoryAddress)
}

public extension ServerHandler {
    
    func didConnect<Socket: MapleStorySocket, Storage: ModelStorage>(connection: MapleStoryServer<Socket, Storage>.Connection) { }
    
    func didDisconnect(address: MapleStoryAddress) { }
}

public protocol PacketHandler {
    
    associatedtype Packet: MapleStoryPacket & Decodable
    
    func handle<Socket: MapleStorySocket, Storage: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Storage>.Connection
    ) async throws
}
