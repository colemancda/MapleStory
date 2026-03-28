//
//  TrockAddMapHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct TrockAddMapHandler: PacketHandler {

    public typealias Packet = MapleStory83.TrockAddMapRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        let inventory = await character.getInventory()

        let hasTrock = inventory[.use].values.contains { $0.itemId == 5_020_000 }
        guard hasTrock else { return }

        guard let rawMapID = packet.mapID else { return }
        let mapID = Map.ID(rawValue: rawMapID)
        guard isValidTrockMap(rawMapID) else { return }

        var trockMaps = character.trockMaps ?? []

        if packet.mode == 0x03 {
            guard !trockMaps.contains(mapID) else { return }
            guard trockMaps.count < 5 else { return }
            trockMaps.append(mapID)
        } else {
            trockMaps.removeAll { $0 == mapID }
        }

        character.trockMaps = trockMaps
        try await connection.database.insert(character)
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    private func isValidTrockMap(_ mapID: UInt32) -> Bool {
        switch mapID {
        case 910000000...999999999:
            return false
        default:
            return true
        }
    }
}
