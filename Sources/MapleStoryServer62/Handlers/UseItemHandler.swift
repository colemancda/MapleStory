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
