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
public struct ServerHandler <Socket: MapleStorySocket, Database: CoreModel.ModelStorage, ClientOpcode: MapleStoryOpcode, ServerOpcode: MapleStoryOpcode> {
    
    public var didConnect: (MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection) -> ()
    
    public var didDisconnect: (MapleStoryAddress) -> ()
    
    public init(
        didConnect: @escaping (MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection) -> () = { _ in },
        didDisconnect: @escaping (MapleStoryAddress) -> () = { _ in }
    ) {
        self.didConnect = didConnect
        self.didDisconnect = didDisconnect
    }
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
