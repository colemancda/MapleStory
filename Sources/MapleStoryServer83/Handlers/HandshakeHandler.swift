//
//  HandshakeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/28/24.
//

import Foundation
import MapleStory83
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
        let packet = await MapleStory83.HelloPacket(
            recieveNonce: await connection.recieveNonce,
            sendNonce: await connection.sendNonce,
            region: connection.region
        )
        try await connection.send(packet)
        await connection.encrypt()
    }
}
