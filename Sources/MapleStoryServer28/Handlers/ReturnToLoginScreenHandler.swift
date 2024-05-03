//
//  ReturnToLoginScreenHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct ReturnToLoginScreenHandler: PacketHandler {
        
    public typealias Packet = MapleStory28.ReturnToLoginScreenRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = ReturnToLoginScreenResponse()
        try await connection.send(response)
    }
}
