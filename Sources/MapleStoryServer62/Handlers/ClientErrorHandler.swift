//
//  ClientError.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct ClientErrorHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.ClientStartError
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // TODO: Store in database
        NSLog("Client error\n\(packet.error)")
    }
}
