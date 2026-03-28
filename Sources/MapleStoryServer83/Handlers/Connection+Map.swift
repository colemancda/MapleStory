//
//  Connection+Map.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory83.ClientOpcode, ServerOpcode == MapleStory83.ServerOpcode {

    // MARK: - Map Data

    func mapData(id: Map.ID) async -> WzMap? {
        await MapDataCache.shared.map(id: id)
    }

    // MARK: - Player Position

    func playerPosition(for characterID: Character.ID) async -> PlayerPosition? {
        await PlayerPositionRegistry.shared.position(for: characterID)
    }

    func updatePlayerPosition(_ position: PlayerPosition, for characterID: Character.ID) async {
        await PlayerPositionRegistry.shared.updatePosition(position, for: characterID)
    }

    func isPlayerInRange(characterID: Character.ID, position: PlayerPosition, range: Int16) async -> Bool {
        await PlayerPositionRegistry.shared.isInRange(characterID: characterID, position: position, range: range)
    }

    func portalSpawnPoint(named portalName: String, in mapID: Map.ID) async -> UInt8 {
        guard let mapData = await mapData(id: mapID) else { return 0 }
        guard let index = mapData.portals.firstIndex(where: { $0.name == portalName }) else { return 0 }
        return UInt8(index)
    }

    // MARK: - Map Items (drops)

    func mapDrop(objectID: UInt32, on mapID: Map.ID) async -> MapItemRegistry.Drop? {
        await MapItemRegistry.shared.drop(objectID: objectID, on: mapID)
    }

    func removeMapDrop(objectID: UInt32, from mapID: Map.ID) async {
        await MapItemRegistry.shared.removeDrop(objectID: objectID, from: mapID)
    }

    // MARK: - Doors

    func findDoor(ownerID: Character.ID, in mapID: Map.ID) async -> Door? {
        await DoorRegistry.shared.find(ownerID: ownerID, in: mapID)
    }

    func registerDoor(_ door: Door) async {
        await DoorRegistry.shared.register(door)
    }

    func removeDoor(ownerID: Character.ID) async {
        await DoorRegistry.shared.remove(ownerID: ownerID)
    }
}
