//
//  UseItemEffectHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles item effect usage (visual effects from use items).
///
/// Many use items grant temporary visual effects when used:
/// - **Stat boosts**: Increase STR/DEX/INT/LUK temporarily
/// - **Visual effects**: Glow, aura, sparkle effects
/// - **Special animations**: Character transformation effects
///
/// # Common Item Effects
///
/// | Item Type | Effect |
/// |------|--------|
/// | Transformation potions | Stat boost + visual effect |
/// | Stat potions | Direct stat increase |
/// | Special items | Unique visual effects |
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Item effects are not yet implemented.
///
/// # TODO
///
/// - Apply item effect stats
/// - Show visual effect animation
/// - Broadcast effect to other players
/// - Set effect expiration timer
public struct UseItemEffectHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseItemEffectRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // If non-zero, validate the item exists in the CASH inventory
        if packet.itemID != 0 {
            let inventory = await character.getInventory()
            guard inventory.cash.values.contains(where: { $0.itemId == packet.itemID }) else {
                return
            }
        }

        // Broadcast the effect to other players on the map (sender's client handles it locally)
        try await connection.broadcast(
            ShowItemEffectNotification(characterID: character.index, itemID: packet.itemID),
            map: character.currentMap
        )
    }
}
