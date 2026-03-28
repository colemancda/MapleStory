//
//  ChangeMapSpecialHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct ChangeMapSpecialHandler: PacketHandler {

    public typealias Packet = MapleStory83.ChangeMapSpecialRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        guard let mapData = await connection.mapData(id: character.currentMap) else { return }
        guard let portal = mapData.portals.first(where: { $0.name == packet.startwp }) else { return }

        let targetMapID = Map.ID(rawValue: portal.targetMap)
        let spawnPoint = await connection.portalSpawnPoint(named: portal.targetName, in: targetMapID)

        try await connection.warp(to: targetMapID, spawn: spawnPoint)
        try await connection.database.insert(character)
    }
}
