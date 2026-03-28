//
//  UseSummonBagHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct UseSummonBagHandler: PacketHandler {

    public typealias Packet = MapleStory83.UseSummonBagRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        let positionRegistry = PlayerPositionRegistry.shared
        let playerPosition = await positionRegistry.position(for: character.id)
        guard playerPosition != nil else { return }

        let inventory = await character.getInventory()
        guard let bagItem = inventory[.use][Int8(packet.slot)] else { return }
        guard bagItem.itemId == packet.itemID else { return }
        guard isSummonBag(packet.itemID) else { return }

        guard let summonData = await SummonBagDataCache.shared.data(for: packet.itemID) else { return }

        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)

        let mobRegistry = MapMobRegistry.shared
        let mapID = character.currentMap

        for summon in summonData.mobs {
            let roll = Int.random(in: 1...100)
            if roll <= summon.chance {
                guard let mobTemplate = await MobDataCache.shared.mob(id: summon.mobID) else { continue }

                let oid = await mobRegistry.nextObjectID()
                let mobPosition = playerPosition!

                let instance = MapMobRegistry.MobInstance(
                    objectID: oid,
                    mobID: summon.mobID,
                    mapID: mapID,
                    currentHP: mobTemplate.maxHP,
                    maxHP: mobTemplate.maxHP,
                    x: mobPosition.x,
                    y: mobPosition.y,
                    foothold: 0,
                    rx0: Int16(mobPosition.x - 100),
                    rx1: Int16(mobPosition.x + 100),
                    facing: 0,
                    mobTime: 0
                )

                await mobRegistry.addMob(instance)

                let controller = await mobRegistry.controller(for: mapID)
                if let controllerAddress = controller, controllerAddress == connection.address {
                    try await connection.send(SpawnMonsterControl(control: 2, mob: instance.toSpawnData()))
                }

                try await connection.broadcast(SpawnMonsterNotification(mob: instance.toSpawnData()), map: mapID)
            }
        }

        try await connection.database.insert(character)
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    private func isSummonBag(_ itemID: UInt32) -> Bool {
        return itemID >= 2_100_000 && itemID < 2_101_000
    }
}
