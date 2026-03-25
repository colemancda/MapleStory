//
//  HealOverTimeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles passive HP/MP regeneration over time.
///
/// # Natural Regeneration
///
** Players regenerate HP/MP automatically:
/// - **Triggers**: Every ~10 seconds while standing/sitting
/// - **HP regen**: +8-30 HP per tick (based on MAXHP)
/// - **MP regen**: +3-10 MP per tick (based on MAXMP)
/// - **Sitting bonus**: 1.5x regeneration rate
/// - **Chair bonus**: 2x regeneration rate
/// - **No regen**: While jumping, attacking, or being attacked
///
/// # Regeneration Formula
///
/// Actual regen amounts are calculated by client:
/// ```
/// HP Regen = MAXHP / 500 + 10
/// MP Regen = MAXMP / 500 + 3
///
/// Sitting multiplies regen by 1.5
/// Chairs multiply regen by 2.0
/// ```
///
/// # Anti-Cheat
///
/// - **HP cap**: Maximum 140 HP per tick to prevent exploit
/// - **MP cap**: No explicit cap (MP regen is naturally limited)
/// - **Max validation**: Can't heal above MAXHP/MAXMP
/// - **No negative**: HP/MP can't decrease from regen
///
** Prevents hacks that would:
/// - Fake massive HP regen packets
/// - Instantly heal to full HP
/// - Bypass potion limitations
///
/// # Client Calculation
///
/// The client calculates and sends regen:
/// - Server trusts client for regen amounts
/// - Server validates and caps values
/// - Server updates character in database
/// - Server sends stat update notification
///
/// # Regeneration Stops
///
** Regeneration is interrupted by:
/// - **Taking damage**: Reset regen timer
/// - **Attacking**: Pause regen
/// - **Using skill**: Pause regen
/// - **Changing maps**: Reset regen timer
/// - **Entering Cash Shop**: Stop regen
///
/// # Recovery Items
///
** Other HP/MP recovery methods:
/// - **Potions**: Instant HP/MP restore
/// - **Food**: Gradual HP/MP restore over time
/// - **Heal skill**: Cleric/Priest healing spell
/// - **Recovery chairs**: Bonus regen while sitting
/// - **Party buff**: Holy Symbol (+50% EXP, affects some heals)
///
/// # Chair System
///
** Chairs provide bonus regen:
/// - **Regular chairs**: 1.5x regen rate
/// - **Recovery chairs**: 2x regen rate
/// - **Must be sitting**: Can't move or attack
/// - **Portable**: Can use anywhere (except some maps)
/// - **Consumable**: Some chairs have limited uses
///
/// # Skill Effects
///
** Some skills affect regen:
/// - **Recovery** (Beginner): Passive HP regen boost
/// - **Improving MP Recovery** (Mage): Passive MP regen boost
/// - **Heal** (Cleric): Active heal spell
/// - **Dispel**: Removes debuffs that block regen
///
/// # Database Persistence
///
** Character HP/MP saved immediately:
/// - Prevents rollback on server crash
/// - Ensures regen isn't lost
/// - Player sees updated HP/MP bar
///
** Not announced (no popup):
/// - `announce: false` in stat update
/// - Quiet update to HP/MP bar only
/// - Unlike potion pickup (which shows popup)
public struct HealOverTimeHandler: PacketHandler {

    public typealias Packet = MapleStory62.HealOverTimeRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        // Cap HP regen at 140 to prevent exploit.
        let healHP = min(packet.hp, 140)
        let healMP = packet.mp

        var changedStats: MapleStat = []

        if healHP > 0, character.hp < character.maxHp {
            let newHp = min(UInt32(character.hp) + UInt32(healHP), UInt32(character.maxHp))
            character.hp = UInt16(newHp)
            changedStats.formUnion(.hp)
        }

        if healMP > 0, character.mp < character.maxMp {
            let newMp = min(UInt32(character.mp) + UInt32(healMP), UInt32(character.maxMp))
            character.mp = UInt16(newMp)
            changedStats.formUnion(.mp)
        }

        guard !changedStats.isEmpty else { return }

        try await connection.database.insert(character)

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
}
