//
//  UseItemHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles consumable item usage (potions, food, etc.).
///
/// # Consumable Items
///
/// This handler processes items from the USE inventory (type 2) that:
/// - Restore HP/MP (potions, food)
/// - Grant temporary buffs
/// - Teleport player
/// - Grant experience
/// - Remove debuffs
///
/// # HP/MP Recovery Formula
///
/// ## Flat Recovery
/// - Potion heals fixed amount (e.g., 50 HP)
/// - Simple addition to current HP/MP
/// - Cannot exceed max HP/MP
///
/// ## Percentage Recovery
/// - Heals percentage of max HP/MP (e.g., 50%)
/// - Formula: `gain = (maxHP * percent / 100) + flatAmount`
/// - Used for items like "Ginger Ale" (50% HP/MP)
///
/// ## Combined Recovery
/// - Many items have both flat and percentage components
/// - Example: 100 HP + 50% = 100 + (maxHP * 0.5)
/// - Both components stack
///
/// # Item Consumption
///
/// - **Quantity > 1**: Decrease quantity by 1
/// - **Quantity == 1**: Remove item from inventory
/// - Inventory slot becomes empty after last use
///
/// # Item Validation
///
/// - Item must exist in USE inventory at specified slot
/// - Item must be consumable (defined in WZ data)
/// - Player must be alive (usually enforced elsewhere)
///
/// # Stat Updates
///
/// Only stats that changed are sent to client:
/// - If HP changed: Send HP update
/// - If MP changed: Send MP update
/// - If both changed: Send both
/// - `announce: false` prevents popup for potion use
///
/// # Future Features (TODO)
///
/// ## Buff Items
/// - Items with `time > 0` grant temporary stat boosts
/// - Examples: Warrior Pill, Wizard Elixir
/// - Should apply buff through `CharacterBuffRegistry`
///
/// ## Teleport Items
/// - Items with `moveTo != -1` teleport player
/// - Examples: Teleport rocks, VIP rocks
/// - Should warp player to saved location
///
/// ## EXP Items
/// - Items with `exp > 0` grant experience
/// - Examples: EXP cards, event items
/// - Should add EXP and handle EXP caps
///
/// # Anti-Cheat Considerations
///
/// - Server validates item existence (no hacking items)
/// - Server validates item type (only consumables)
/// - Server applies effects (client can't fake values)
/// - Position registry ensures player is where they say
///
/// # Common Consumables
///
/// ## HP Potions
/// - Red Potion (50 HP), Orange Potion (150 HP), White Potion (300 HP)
/// - Ginger Ale (50% HP/MP), Elixir (50% HP/MP)
///
/// ## MP Potions
/// - Blue Potion (100 MP), Mana Elixir (50% MP), Mana Elixir (50% MP)
///
/// ## Food
/// - Hot Dog (300 HP), Taco (500 HP), Cheeseburger (600 HP)
/// - Hot Dog Supreme (1000 HP)
///
/// # Inventory Slots
///
/// - USE inventory type 2
/// - Slots are 0-based (0-24 for 25 slots)
/// - Client sends slot number of item to use
public struct UseItemHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseItemRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        let inventory = await character.getInventory()

        // Find item in use inventory (type 2)
        let slot = Int8(packet.slot)
        guard let item = inventory[.use][slot] else {
            return // Item doesn't exist
        }

        // Get item data from WZ
        guard let itemData = await ItemDataCache.shared.consume(id: item.itemId) else {
            return // Not a consumable
        }

        // Apply item effects
        var changedStats: MapleStat = []

        // HP recovery (flat or percentage)
        let hpRecovery = itemData.hp
        let hpRateRecovery = itemData.hpRate
        if hpRecovery > 0 || hpRateRecovery > 0 {
            var hpGain = Int32(hpRecovery)
            if hpRateRecovery > 0 {
                let percentGain = Int32(character.maxHp) * hpRateRecovery / 100
                hpGain += percentGain
            }
            character.hp = min(UInt16(Int32(character.hp) + hpGain), character.maxHp)
            changedStats.formUnion(.hp)
        }

        // MP recovery (flat or percentage)
        let mpRecovery = itemData.mp
        let mpRateRecovery = itemData.mpRate
        if mpRecovery > 0 || mpRateRecovery > 0 {
            var mpGain = Int32(mpRecovery)
            if mpRateRecovery > 0 {
                let percentGain = Int32(character.maxMp) * mpRateRecovery / 100
                mpGain += percentGain
            }
            character.mp = min(UInt16(Int32(character.mp) + mpGain), character.maxMp)
            changedStats.formUnion(.mp)
        }

        // Remove consumed item (decrease quantity or remove)
        var updatedInventory = inventory
        if item.quantity > 1 {
            updatedInventory[.use][slot]?.quantity -= 1
        } else {
            updatedInventory[.use][slot] = nil
        }
        await character.setInventory(updatedInventory)

        // Save character
        try await connection.database.insert(character)

        // Send stats update
        if !changedStats.isEmpty {
            let notification = UpdateStatsNotification(
                announce: false,
                stats: changedStats,
                skin: nil, face: nil, hair: nil, level: nil, job: nil,
                str: nil, dex: nil, int: nil, luk: nil,
                hp: changedStats.contains(.hp) ? character.hp : nil,
                maxHp: nil,
                mp: changedStats.contains(.mp) ? character.mp : nil,
                maxMp: nil,
                ap: nil, sp: nil, exp: nil, fame: nil, meso: nil
            )
            try await connection.send(notification)
        }

        // TODO: Handle buff items (itemData.time > 0)
        // TODO: Handle teleport items (itemData.moveTo != -1)
        // TODO: Handle EXP items (itemData.exp > 0)
    }
}
