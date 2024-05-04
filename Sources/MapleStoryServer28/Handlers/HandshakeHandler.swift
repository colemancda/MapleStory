//
//  HandshakeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation
import MapleStory28
import MapleStoryServer
import CoreModel

public struct HandshakeHandler <Socket: MapleStorySocket, Database: ModelStorage>: ServerHandler {
    
    public func didConnect(
        connection: MapleStoryServer<Socket, Database, MapleStory28.ClientOpcode, MapleStory28.ServerOpcode>.Connection
    ) async {
        Task {
            do {
                try await self.sendHandshake(connection: connection)
            }
            catch {
                await connection.close(error)
            }
        }
    }
    
    public func didDisconnect(address: MapleStoryAddress) async {
        
    }
}

internal extension HandshakeHandler {
    
    func sendHandshake(
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    )  async throws {
        let encoder = MapleStoryEncoder()
        let packet = await MapleStory28.HelloPacket(
            recieveNonce: connection.recieveNonce,
            sendNonce: connection.sendNonce,
            region: connection.region
        )
        let data = try encoder.encode(packet)
        try await connection.send(data)
        await connection.encrypt()
    }
}
