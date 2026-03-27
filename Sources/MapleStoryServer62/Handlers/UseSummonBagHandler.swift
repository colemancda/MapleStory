//
//  UseSummonBagHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles summon bag usage (spawning summoned creatures).
///
/// Summon bags are consumable items that, when used, spawn a
/// a temporary summon creature to aid the player in combat.
///
/// # Summon Types
///
/// - **Skeleton**: Summons skeleton warriors
/// - **Mushroom House**: Summons healing mushrooms
/// - **Octopus**: Summons an octopus ally
///
/// # Flow
///
/// 1. Player uses summon bag item
/// 2. Server validates item exists
/// 3. Server consumes item from inventory
/// 4. Server spawns summon at player's position
/// 5. Server broadcasts spawn to map players
///
public struct UseSummonBagHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseSummonBagRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Validate player is alive
        let positionRegistry = PlayerPositionRegistry.shared
        let playerPosition = await positionRegistry.position(for: character.id)
        guard playerPosition != nil else { return }

        // Get inventory
        let inventory = await character.getInventory()

        // Get summon bag from USE inventory
        guard let bagItem = inventory[.use][Int8(packet.slot)] else {
            return // Item doesn't exist
        }

        // Validate it's the correct item
        guard bagItem.itemId == packet.itemID else {
            return // Item mismatch
        }

        // Validate it's a summon bag (item ID 2100xxx)
        guard isSummonBag(packet.itemID) else {
            return // Not a summon bag
        }

        // Get summon bag data
        guard let summonData = await SummonBagDataCache.shared.data(for: packet.itemID) else {
            return // Unknown summon bag
        }

        // Consume the bag
        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)

        // Spawn mobs based on probability
        let mobRegistry = MapMobRegistry.shared
        let mapID = character.currentMap

        for summon in summonData.mobs {
            let roll = Int.random(in: 1...100)
            if roll <= summon.chance {
                // Get mob template
                guard let mobTemplate = await MobDataCache.shared.mob(id: summon.mobID) else {
                    continue
                }

                // Create mob instance
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
                    mobTime: 0 // Summoned mobs don't respawn
                )

                // Add to registry
                await mobRegistry.addMob(instance)

                // Broadcast spawn to map
                let controller = await mobRegistry.controller(for: mapID)
                if let controllerAddress = controller, controllerAddress == connection.address {
                    // This player is the controller
                    try await connection.send(SpawnMonsterControl(
                        control: 2,
                        mob: instance.toSpawnData()
                    ))
                }

                // Send notification to all players on map
                try await connection.broadcast(SpawnMonsterNotification(mob: instance.toSpawnData()), map: mapID)
            }
        }

        // Save character
        try await connection.database.insert(character)

        // Enable actions
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    // MARK: - Private Helpers

    private func isSummonBag(_ itemID: UInt32) -> Bool {
        // Summon bags are in the 2100xxx range
        return itemID >= 2_100_000 && itemID < 2_101_000
    }
}

// MARK: - Summon Bag Data Cache

/// Cache for summon bag data
public actor SummonBagDataCache {

    public static let shared = SummonBagDataCache()

    private var data: [UInt32: SummonBagData] = [:]

    private init() {
        // Initialize with common summon bags
        var dataDict: [UInt32: SummonBagData] = [:]

        // Skeleton (2100000) - Spawns 1 skeleton (100% chance)
        dataDict[2_100_000] = SummonBagData(mobs: [
            SummonEntry(mobID: 9001009, chance: 100) // Skeleton
        ])

        // Octopus (2100001) - Spawns 1 octopus (100% chance)
        dataDict[2_100_001] = SummonBagData(mobs: [
            SummonEntry(mobID: 9001010, chance: 100) // Octopus
        ])

        // Mushroom House (2100002) - Spawns healing mushroom (100% chance)
        dataDict[2_100_002] = SummonBagData(mobs: [
            SummonEntry(mobID: 9001011, chance: 100) // Mushroom House
        ])

        // Wolf (2100003) - Spawns 1-2 wolves (50% each)
        dataDict[2_100_003] = SummonBagData(mobs: [
            SummonEntry(mobID: 9001012, chance: 50), // Wolf
            SummonEntry(mobID: 9001012, chance: 50) // Wolf (second one)
        ])

        self.data = dataDict
    }

    public func data(for itemID: UInt32) -> SummonBagData? {
        return data[itemID]
    }
}

/// Summon bag data
public struct SummonBagData: Sendable {
    public let mobs: [SummonEntry]
}

/// Individual summon entry
public struct SummonEntry: Sendable {
    public let mobID: UInt32
    public let chance: Int // 0-100
}

// MARK: - MapMobRegistry Extensions

extension MapMobRegistry {

    public func nextObjectID() async -> UInt32 {
        // Note: This is a simplified approach - in production you'd want proper atomic operations
        return 1_000_000_000 + UInt32.random(in: 0...999999)
    }

    public func addMob(_ instance: MobInstance) async {
        // Note: This would need proper implementation in the registry
        // For now, this is a placeholder
    }
}

extension MapMobRegistry.MobInstance {
    func toSpawnData() -> MobSpawnData {
        return MobSpawnData(
            objectID: objectID,
            mobID: mobID,
            x: x,
            y: y,
            foothold: foothold,
            rx0: rx0,
            rx1: rx1,
            facing: facing
        )
    }
}
