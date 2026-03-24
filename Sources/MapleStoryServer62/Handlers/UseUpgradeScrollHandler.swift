//
//  UseUpgradeScrollHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct UseUpgradeScrollHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseUpgradeScrollRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Get inventory
        var inventory = await character.getInventory()

        // Get scroll from USE inventory
        guard let scrollItem = inventory[.use][Int8(packet.slot)] else {
            return // Scroll doesn't exist
        }

        // Validate it's a scroll (item ID 204xxxxx or 233xxxxx for chaos scrolls)
        let scrollID = scrollItem.itemId
        guard isScroll(scrollID) else {
            return // Not a scroll
        }

        // Get equipment from EQUIP inventory
        guard var equipItem = inventory[.equip][Int8(packet.destinationSlot)] else {
            return // Equipment doesn't exist
        }

        guard var equipData = equipItem.equip else {
            return // Not equipment
        }

        // Check if has slots available
        guard equipData.slots > 0 else {
            return // No slots available
        }

        // Get scroll data
        let scrollData = await ScrollDataCache.shared.scroll(scrollID)
        guard let data = scrollData else {
            return // Invalid scroll
        }

        // Determine success
        let successChance = data.successRate
        let destroyedChance = data.destroyChance
        let roll = Int.random(in: 1...100)

        // Check for white scroll (prevents slot usage on failure)
        let hasWhiteScroll = packet.whiteScroll == 1

        var result: ShowScrollEffectNotification.ScrollResult = .failure

        if roll <= successChance {
            // Success! Apply scroll stats
            equipData.str += data.str
            equipData.dex += data.dex
            equipData.int += data.int
            equipData.luk += data.luk
            equipData.hp += data.hp
            equipData.mp += data.mp
            equipData.weaponAttack += data.weaponAttack
            equipData.magicAttack += data.magicAttack
            equipData.weaponDefense += data.weaponDefense
            equipData.magicDefense += data.magicDefense
            equipData.accuracy += data.accuracy
            equipData.avoid += data.avoid
            equipData.speed += data.speed
            equipData.jump += data.jump

            equipData.slots -= 1
            equipItem.equip = equipData
            inventory[.equip][Int8(packet.destinationSlot)] = equipItem

            result = .success
        } else if roll <= (successChance + destroyedChance) {
            // Catastrophic failure - destroy equipment
            inventory[.equip][Int8(packet.destinationSlot)] = nil
            result = .destroyed
        } else {
            // Normal failure - just consume a slot
            if !hasWhiteScroll {
                equipData.slots -= 1
                equipItem.equip = equipData
                inventory[.equip][Int8(packet.destinationSlot)] = equipItem
            }
            result = .failure
        }

        // Update inventory
        await character.setInventory(inventory)

        // Consume the scroll
        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(scrollID, quantity: 1, from: character)

        // Save character
        try await connection.database.insert(character)

        // Send scroll effect notification
        try await connection.send(ShowScrollEffectNotification(
            characterID: character.index,
            result: result,
            position: packet.destinationSlot
        ))
    }

    // MARK: - Private Helpers

    private func isScroll(_ itemID: UInt32) -> Bool {
        let prefix = itemID / 1000000
        return prefix == 204 || prefix == 233 // Chaos scrolls
    }
}

// MARK: - Scroll Data Cache

/// Cache for scroll upgrade data
public actor ScrollDataCache {

    public static let shared = ScrollDataCache()

    private var scrolls: [UInt32: ScrollData] = [:]

    private init() {
        // Initialize with common scrolls inline (avoiding actor-isolated call)
        var scrollsDict: [UInt32: ScrollData] = [:]

        // 100% Scrolls (always work, no destruction)
        scrollsDict[2_040_001] = ScrollData(successRate: 100, destroyChance: 0, str: 1, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_002] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 1, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_003] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 1, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_005] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 1, speed: 0, jump: 0)
        scrollsDict[2_040_006] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 2, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_007] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 2, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_008] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 1, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_009] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 1, jump: 0)
        scrollsDict[2_040_010] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 1)
        scrollsDict[2_040_011] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 2, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_016] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_018] = ScrollData(successRate: 100, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)

        // 60% Scrolls
        scrollsDict[2_040_300] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 1, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_301] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 1, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_302] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 1, speed: 0, jump: 0)
        scrollsDict[2_040_303] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 1)
        scrollsDict[2_040_304] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 1, jump: 0)
        scrollsDict[2_040_305] = ScrollData(successRate: 60, destroyChance: 0, str: 1, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_306] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 1, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_307] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 1, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_308] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 1, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_309] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 1, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_310] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_311] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_312] = ScrollData(successRate: 60, destroyChance: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)

        // 10% Scrolls
        scrollsDict[2_040_400] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 5, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_401] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 3, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_402] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 3, speed: 0, jump: 0)
        scrollsDict[2_040_403] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 3)
        scrollsDict[2_040_404] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 3, jump: 0)
        scrollsDict[2_040_405] = ScrollData(successRate: 10, destroyChance: 50, str: 3, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_406] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 3, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_407] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 3, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_408] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 3, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_409] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 3, weaponDefense: 0, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_410] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 5, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)
        scrollsDict[2_040_411] = ScrollData(successRate: 10, destroyChance: 50, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, weaponAttack: 0, magicAttack: 0, weaponDefense: 5, magicDefense: 0, accuracy: 0, avoid: 0, speed: 0, jump: 0)

        self.scrolls = scrollsDict
    }

    public func scroll(_ itemID: UInt32) -> ScrollData? {
        return scrolls[itemID]
    }
}

/// Scroll upgrade data
public struct ScrollData: Sendable {
    public let successRate: Int        // 0-100
    public let destroyChance: Int      // 0-100 (on failure)
    public let str: UInt16
    public let dex: UInt16
    public let int: UInt16
    public let luk: UInt16
    public let hp: UInt16
    public let mp: UInt16
    public let weaponAttack: UInt16
    public let magicAttack: UInt16
    public let weaponDefense: UInt16
    public let magicDefense: UInt16
    public let accuracy: UInt16
    public let avoid: UInt16
    public let speed: UInt16
    public let jump: UInt16

    public init(
        successRate: Int,
        destroyChance: Int,
        str: UInt16 = 0,
        dex: UInt16 = 0,
        int: UInt16 = 0,
        luk: UInt16 = 0,
        hp: UInt16 = 0,
        mp: UInt16 = 0,
        weaponAttack: UInt16 = 0,
        magicAttack: UInt16 = 0,
        weaponDefense: UInt16 = 0,
        magicDefense: UInt16 = 0,
        accuracy: UInt16 = 0,
        avoid: UInt16 = 0,
        speed: UInt16 = 0,
        jump: UInt16 = 0
    ) {
        self.successRate = successRate
        self.destroyChance = destroyChance
        self.str = str
        self.dex = dex
        self.int = int
        self.luk = luk
        self.hp = hp
        self.mp = mp
        self.weaponAttack = weaponAttack
        self.magicAttack = magicAttack
        self.weaponDefense = weaponDefense
        self.magicDefense = magicDefense
        self.accuracy = accuracy
        self.avoid = avoid
        self.speed = speed
        self.jump = jump
    }
}
