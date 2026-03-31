//
//  TrockAddMapHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer
import MapleStoryServer62

public struct TrockAddMapHandler: PacketHandler {

    public typealias Packet = MapleStory83.TrockAddMapRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        var maps = character.trockMaps ?? []

        if packet.type == 0x00 {
            guard let rawMapID = packet.mapID else { return }
            let mapID = Map.ID(rawValue: rawMapID)
            maps.removeAll { $0 == mapID }
        } else if packet.type == 0x01 {
            let mapID = character.currentMap
            guard !maps.contains(mapID), maps.count < 5 else { return }
            maps.append(mapID)
        } else {
            return
        }

        character.trockMaps = maps
        try await connection.database.insert(character)
    }
}
