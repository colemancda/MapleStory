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

public struct HandshakeHandler {
        
    public static func didConnect<Socket, Storage>(
        connection: MapleStoryServer<Socket, Storage, ClientOpcode, ServerOpcode>.Connection
    ) where Socket : MapleStorySocket, Storage : ModelStorage {
        Task {
            do {
                try await sendHandshake(connection: connection)
            }
            catch {
                await connection.close(error)
            }
        }
    }
}

internal extension HandshakeHandler {
    
    static func sendHandshake<Socket: MapleStorySocket, Storage: ModelStorage>(
        connection: MapleStoryServer<Socket, Storage, ClientOpcode, ServerOpcode>.Connection
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
