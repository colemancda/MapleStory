//
//  CancelChairHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct CancelChairHandler: PacketHandler {

    public typealias Packet = MapleStory62.CancelChairRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Cancel chair - send cancel chair packet to client
        // This removes the chair effect on the client side
        try await connection.send(CancelChairNotification(
            characterID: character.index
        ))
    }
}
