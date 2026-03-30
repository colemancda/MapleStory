//
//  UseItemHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct UseItemHandler: PacketHandler {

    public typealias Packet = MapleStory83.UseItemRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        // Cannot use items while dead.
        guard character.hp > 0 else {
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        let inventory = await character.getInventory()
        let slot = Int8(packet.slot)
        guard let item = inventory[.use][slot] else { return }
        guard item.itemId == packet.itemID else { return }

        guard let itemData = await connection.consumeItemData(id: item.itemId) else { return }

        // Remove one from the stack.
        var updatedInventory = inventory
        if item.quantity > 1 {
            updatedInventory[.use][slot]?.quantity -= 1
        } else {
            updatedInventory[.use][slot] = nil
        }
        await character.setInventory(updatedInventory)

        // Special items — dispel debuffs or apply area effects.
        switch item.itemId {
        case 2050004: // ALL_CURE_POTION: remove all debuffs
            await connection.dispelAllDebuffs(from: character.id)
            try await connection.database.insert(character)
            try await connection.send(UpdateStatsNotification.enableActions)
            return

        case 2050001: // EYEDROP: remove darkness
            await connection.dispelDebuff(.darkness, from: character.id)
            try await connection.database.insert(character)
            try await connection.send(UpdateStatsNotification.enableActions)
            return

        case 2050002: // TONIC: remove weaken + slow
            await connection.dispelDebuff(.weaken, from: character.id)
            await connection.dispelDebuff(.slow, from: character.id)
            try await connection.database.insert(character)
            try await connection.send(UpdateStatsNotification.enableActions)
            return

        case 2050003: // HOLY_WATER: remove seal + curse
            await connection.dispelDebuff(.seal, from: character.id)
            await connection.dispelDebuff(.curse, from: character.id)
            try await connection.database.insert(character)
            try await connection.send(UpdateStatsNotification.enableActions)
            return

        default:
            break
        }

        // Town scrolls: handled as teleport items (stub).
        if isTownScroll(item.itemId) {
            try await connection.database.insert(character)
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        // Standard HP/MP recovery.
        var changedStats: MapleStat = []

        let hpRecovery = itemData.hp
        let hpRateRecovery = itemData.hpRate
        if hpRecovery > 0 || hpRateRecovery > 0 {
            var hpGain = Int32(hpRecovery)
            if hpRateRecovery > 0 {
                hpGain += Int32(character.maxHp) * hpRateRecovery / 100
            }
            character.hp = min(UInt16(Int32(character.hp) + hpGain), character.maxHp)
            changedStats.formUnion(.hp)
        }

        let mpRecovery = itemData.mp
        let mpRateRecovery = itemData.mpRate
        if mpRecovery > 0 || mpRateRecovery > 0 {
            var mpGain = Int32(mpRecovery)
            if mpRateRecovery > 0 {
                mpGain += Int32(character.maxMp) * mpRateRecovery / 100
            }
            character.mp = min(UInt16(Int32(character.mp) + mpGain), character.maxMp)
            changedStats.formUnion(.mp)
        }

        await character.setInventory(updatedInventory)
        try await connection.database.insert(character)

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
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    // MARK: - Private

    private func isTownScroll(_ itemID: UInt32) -> Bool {
        return itemID >= 2030000 && itemID < 2040000
    }
}
