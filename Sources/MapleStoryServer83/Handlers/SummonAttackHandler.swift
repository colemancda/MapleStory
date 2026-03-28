//
//  SummonAttackHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct SummonAttackHandler: PacketHandler {

    public typealias Packet = MapleStory83.SummonAttackRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let mapID = await connection.mapID else { return }

        try await connection.broadcast(SummonAttackNotification(
            characterID: character.index,
            objectID: packet.objectID,
            numAttacked: packet.numAttacked
        ), map: mapID)
    }
}
