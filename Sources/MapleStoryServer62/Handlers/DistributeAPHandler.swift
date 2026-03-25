//
//  DistributeAPHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles AP (Ability Point) distribution to character stats.
///
/// # Ability Points (AP)
///
/// - Players earn AP when leveling up
/// - AP can be distributed to: STR, DEX, INT, LUK, HP, MP
/// - Each stat increase costs 1 AP
/// - AP persists until used
/// - Can be reallocated using SP resets (NX cash item)
///
/// # Stat Distribution
///
/// ## Primary Stats (STR, DEX, INT, LUK)
/// - **Cost**: 1 AP per +1
/// - **Max**: 999 per stat (hard cap)
/// - **Purpose**: Increases damage, accuracy, avoidance
/// - **Stat codes**:
///   - STR: 64
///   - DEX: 128
///   - INT: 256
///   - LUK: 512
///
/// ## Secondary Stats (HP, MP)
/// - **Cost**: 1 AP per random gain
/// - **HP Gain**: Job-dependent (see below)
/// - **MP Gain**: Job-dependent (see below)
/// - **Max**: 30,000 HP/MP (hard cap)
/// - **Stat codes**:
///   - HP: 2048
///   - MP: 8192
///
/// # HP/MP Gains by Job
///
/// ## HP Gain Per AP
/// - **Warrior**: 20-24 HP (highest HP growth)
/// - **Bowman**: 16-20 HP
/// - **Thief**: 16-20 HP
/// - **Pirate**: 18-22 HP
/// - **Magician**: 8-12 HP (lowest HP growth)
/// - **Beginner**: 8-12 HP
///
/// ## MP Gain Per AP
/// - **Magician**: 18-22 MP (highest MP growth)
/// - **Bowman**: 10-12 MP
/// - **Thief**: 10-12 MP
/// - **Pirate**: 14-16 MP
/// - **Warrior**: 2-4 MP (lowest MP growth)
/// - **Beginner**: 6-8 MP
///
/// # Allocation Strategy
///
/// ## Early Game
/// - Beginners distribute AP to match job requirements
/// - Typical distribution depends on chosen class
///
/// ## Warrior
/// - Focus: STR primary, DEX secondary
/// - INT/LUK: Leave at default (4)
/// - HP gains benefit from STR
///
/// ## Magician
/// - Focus: INT primary, LUK secondary (for accuracy)
/// - STR/DEX: Leave at default (4)
/// - MP gains benefit from INT
///
/// ## Bowman
/// - Focus: DEX primary, STR secondary
/// - INT/LUK: Leave at default (4)
/// - Balanced HP/MP gains
///
/// ## Thief
/// - Focus: LUK primary, DEX secondary
/// - STR/INT: Leave at default (4)
/// - Balanced HP/MP gains
///
/// # AP Source
///
/// ## Leveling Up
/// - Each level grants AP (5 at level 10+)
/// - Amount increases at certain levels
/// - Total AP gained = sum of all levels
///
/// ## Quest Rewards
/// - Some quests grant AP as rewards
/// - Can exceed normal AP pool
///
/// ## Cash Shop
/// - AP resets available for NX
/// - Reallocation allowed
///
/// # Stat Requirements
///
/// Some equipment has stat requirements:
/// - Weapons: STR, DEX, INT, LUK requirements
/// - Armor: Job-specific stat requirements
/// - Players must meet requirements to equip
///
/// # Validation
///
/// - Must have at least 1 AP to distribute
/// - Stat cannot exceed 999 (primary) or 30,000 (HP/MP)
/// - Invalid stat codes are rejected
///
/// # Client Notification
///
/// - **announce: true**: Shows stat increase popup
/// - Shows exact stat values after increase
/// - Client plays "level up" sound effect
///
/// # Rollback
///
/// - AP allocation is permanent
/// - Can only reset with NX cash items
/// - SP (Skill Points) are separate system
///
/// # Related Systems
///
/// - **DistributeSPHandler**: Skill point distribution
/// - **LevelUpHandler**: Grants AP when leveling
/// - **EquipmentHandler**: Validates stat requirements
/// - **CashShop**: Sells AP resets
///
/// # Anti-Cheat
///
/// - Server tracks actual AP on server
/// - Client can't allocate AP they don't have
/// - Server validates all allocations
/// - Prevents stat hacking
public struct DistributeAPHandler: PacketHandler {

    public typealias Packet = MapleStory62.DistributeAPRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }
        guard character.ap > 0 else { return }

        var changedStats: MapleStat = .availableAP
        character.ap -= 1

        switch packet.stat {
        case 64:   // STR
            character.str = min(character.str + 1, 999)
            changedStats.formUnion(.str)
        case 128:  // DEX
            character.dex = min(character.dex + 1, 999)
            changedStats.formUnion(.dex)
        case 256:  // INT
            character.int = min(character.int + 1, 999)
            changedStats.formUnion(.int)
        case 512:  // LUK
            character.luk = min(character.luk + 1, 999)
            changedStats.formUnion(.luk)
        case 2048: // HP
            let gain = hpGainForJob(character.job)
            let newMax = min(UInt32(character.maxHp) + UInt32(gain), 30000)
            character.maxHp = UInt16(newMax)
            character.hp = min(character.hp, character.maxHp)
            changedStats.formUnion([.maxHP, .hp])
        case 8192: // MP
            let gain = mpGainForJob(character.job)
            let newMax = min(UInt32(character.maxMp) + UInt32(gain), 30000)
            character.maxMp = UInt16(newMax)
            character.mp = min(character.mp, character.maxMp)
            changedStats.formUnion([.maxMP, .mp])
        default:
            return
        }

        try await connection.database.insert(character)

        let notification = UpdateStatsNotification(
            announce: true,
            stats: changedStats,
            skin: nil, face: nil, hair: nil, level: nil, job: nil,
            str: changedStats.contains(.str) ? character.str : nil,
            dex: changedStats.contains(.dex) ? character.dex : nil,
            int: changedStats.contains(.int) ? character.int : nil,
            luk: changedStats.contains(.luk) ? character.luk : nil,
            hp: changedStats.contains(.hp) ? character.hp : nil,
            maxHp: changedStats.contains(.maxHP) ? character.maxHp : nil,
            mp: changedStats.contains(.mp) ? character.mp : nil,
            maxMp: changedStats.contains(.maxMP) ? character.maxMp : nil,
            ap: character.ap,
            sp: nil, exp: nil, fame: nil, meso: nil
        )
        try await connection.send(notification)
    }

    // MARK: - Job-based gains

    private func hpGainForJob(_ job: Job) -> UInt16 {
        switch job.type {
        case .warrior:         return UInt16.random(in: 20...24)
        case .magician:        return UInt16.random(in: 6...10)
        case .bowman:          return UInt16.random(in: 16...20)
        case .thief:           return UInt16.random(in: 16...20)
        case .pirate:          return UInt16.random(in: 18...22)
        default:               return UInt16.random(in: 8...12)
        }
    }

    private func mpGainForJob(_ job: Job) -> UInt16 {
        switch job.type {
        case .warrior:         return UInt16.random(in: 2...4)
        case .magician:        return UInt16.random(in: 18...22)
        case .bowman:          return UInt16.random(in: 10...12)
        case .thief:           return UInt16.random(in: 10...12)
        case .pirate:          return UInt16.random(in: 14...16)
        default:               return UInt16.random(in: 6...8)
        }
    }
}
