//
//  PetTalkHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct PetTalkHandler: PacketHandler {

    public typealias Packet = MapleStory62.PetTalkRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let _ = try await connection.character else { return }
        try await connection.send(ServerMessageNotification.notice(
            message: "Pet talk is not available yet."
        ))
    }
}
