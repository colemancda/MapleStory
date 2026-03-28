//
//  UseUpgradeScrollHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct UseUpgradeScrollHandler: PacketHandler {

    public typealias Packet = MapleStory83.UseUpgradeScrollRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        var inventory = await character.getInventory()

        guard let scrollItem = inventory[.use][Int8(packet.slot)] else { return }
        let scrollID = scrollItem.itemId
        guard isScroll(scrollID) else { return }

        guard var equipItem = inventory[.equip][Int8(packet.destinationSlot)] else { return }
        guard var equipData = equipItem.equip else { return }
        guard equipData.slots > 0 else { return }

        let scrollData = await connection.scrollData(id: scrollID)
        guard let data = scrollData else { return }

        let successChance = data.successRate
        let destroyedChance = data.destroyChance
        let roll = Int.random(in: 1...100)
        let hasWhiteScroll = packet.whiteScroll == 1

        var result: ShowScrollEffectNotification.ScrollResult = .failure

        if roll <= successChance {
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
            inventory[.equip][Int8(packet.destinationSlot)] = nil
            result = .destroyed
        } else {
            if !hasWhiteScroll {
                equipData.slots -= 1
                equipItem.equip = equipData
                inventory[.equip][Int8(packet.destinationSlot)] = equipItem
            }
            result = .failure
        }

        await character.setInventory(inventory)

        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(scrollID, quantity: 1, from: character)

        try await connection.database.insert(character)

        try await connection.send(ShowScrollEffectNotification(
            characterID: character.index,
            result: result,
            position: packet.destinationSlot
        ))
    }

    private func isScroll(_ itemID: UInt32) -> Bool {
        let prefix = itemID / 1000000
        return prefix == 204 || prefix == 233
    }
}
