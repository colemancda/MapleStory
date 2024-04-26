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
    
    associatedtype Socket: MapleStorySocket
    
    associatedtype Storage: ModelStorage
    
    var connection: MapleStoryServer<Socket, Storage>.Connection { get }
    
    init(connection: MapleStoryServer<Socket, Storage>.Connection)
    
    func didConnect()
    
    func didDisconnect()
}

public extension ServerHandler {
    
    func didConnect() { }
    
    func didDisconnect() { }
}

public protocol PacketHandler: ServerHandler {
    
    associatedtype Packet: MapleStoryPacket
    
    func handle(packet: Packet) async throws
}
