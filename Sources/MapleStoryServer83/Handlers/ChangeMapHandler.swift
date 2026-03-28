//
//  ChangeMapHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct ChangeMapHandler: PacketHandler {

    public typealias Packet = MapleStory83.ChangeMapRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else {
            return
        }

        let isDeathWarp = packet.type == 1

        if isDeathWarp {
            try await connection.warp(to: character.currentMap, spawn: character.spawnPoint)
        } else {
            if packet.targetMap == 0x3B9AC9FF {
                return
            }

            guard let mapData = await connection.mapData(id: character.currentMap) else {
                return
            }
            guard let portal = mapData.portals.first(where: { $0.name == packet.portalName }) else {
                return
            }

            let targetMapID = Map.ID(rawValue: portal.targetMap)
            let spawnPoint = await connection.portalSpawnPoint(named: portal.targetName, in: targetMapID)

            try await connection.warp(to: targetMapID, spawn: spawnPoint)
        }

        try await connection.database.insert(character)
    }
}
