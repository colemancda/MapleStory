//
//  UseReturnScrollHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct UseReturnScrollHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseReturnScrollRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Determine return destination based on current map
        let returnMap = getReturnTown(for: character.currentMap)
        try await connection.warp(to: returnMap, spawn: 0)
    }

    // MARK: - Private Helpers

    /// Get return town map for a given map
    private func getReturnTown(for mapID: Map.ID) -> Map.ID {
        // Simplified return town mapping
        // In a full implementation, this would be a comprehensive lookup table

        switch mapID.rawValue {
        // Victoria Island towns
        case 100000000...200000000:
            return Map.ID(rawValue: 100000000) // Henesys

        // Ellinia maps -> return to Ellinia
        case 101000000, 101000001, 101000002, 101000003, 101000004:
            return Map.ID(rawValue: 101000000) // Ellinia

        // Perion maps -> return to Perion
        case 102000000, 102000001, 102000003, 102000005:
            return Map.ID(rawValue: 102000000) // Perion

        // Kerning City maps -> return to Kerning
        case 103000000, 103000001, 103000004, 103000005:
            return Map.ID(rawValue: 103000000) // Kerning

        // Lith Harbor maps -> return to Lith Harbor
        case 104000000, 104000001:
            return Map.ID(rawValue: 104000000) // Lith Harbor

        // Default: return to Henesys
        default:
            return Map.ID(rawValue: 100000000) // Henesys
        }
    }
}
