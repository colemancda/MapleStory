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

public struct HandshakeHandler: ServerHandler {
    
    public func didConnect<Socket, Storage>(
        connection: MapleStoryServer<Socket, Storage>.Connection
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
    
    func sendHandshake<Socket: MapleStorySocket, Storage: ModelStorage>(
        connection: MapleStoryServer<Socket, Storage>.Connection
    )  async throws {
        let packet = await MapleStory28.HelloPacket(
            recieveNonce: connection.recieveNonce,
            sendNonce: connection.sendNonce,
            region: connection.region
        )
        try await connection.send(packet)
        await connection.encrypt()
    }
}
