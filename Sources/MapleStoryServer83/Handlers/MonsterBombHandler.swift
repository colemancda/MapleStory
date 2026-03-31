//
//  MonsterBombHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct MonsterBombHandler: PacketHandler {

    public typealias Packet = MapleStory83.MonsterBombRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard character.hp > 0 else { return }
        guard let mapID = await connection.mapID else { return }

        guard let mob = await connection.mobInstance(objectID: packet.objectID) else { return }
        guard mob.mobID == MonsterBombHandler.highDarkstarID || mob.mobID == MonsterBombHandler.lowDarkstarID else {
            return
        }

        try await connection.broadcast(
            KillMonsterNotification(objectID: packet.objectID, animation: 4),
            map: mapID
        )
        await connection.removeMob(objectID: packet.objectID)
    }

    // MARK: - Private

    private static let highDarkstarID: UInt32 = 8500003
    private static let lowDarkstarID: UInt32 = 8500004
}
