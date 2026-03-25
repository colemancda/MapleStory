//
//  PlayerLoginRequestHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles the player login request when entering a channel after character selection.
///
/// This handler is called when a player has selected their character and is
/// transitioning from the login/character-select server to a channel server.
/// It sets up all the necessary state for the player to begin gameplay.
///
/// # Login Flow
///
/// 1. Player selects character on character select screen
/// 2. Client connects to channel server
/// 3. Client sends `PlayerLoginRequest` with character ID
/// 4. Server calls `playerLogin()` to authenticate and load character data
/// 5. Server loads character skills, quests, keymap from database
/// 6. Server sends `WarpToMapNotification` with full character info
/// 7. Server sends current map mob spawns
/// 8. Player appears in game world
///
/// # Data Loaded on Login
///
/// - **Character**: Stats, equipment, inventory, mesos
/// - **Skills**: Active skills and levels from `CharacterSkillRegistry`
/// - **Quests**: Completed/in-progress quests from database
/// - **Keymap**: Key bindings from `KeymapRegistry`
///
/// # WarpToMapNotification
///
/// The initial `WarpToMapNotification` contains comprehensive character info:
/// - Character stats (HP, MP, STR, DEX, INT, LUK, etc.)
/// - Current map and spawn point
/// - Inventory slot counts
/// - Buddy list size
/// - Random values for client-side state
///
/// # Channel Association
///
/// The handler stores the channel ID it's associated with so it can
/// properly register the player in that specific channel.
public struct PlayerLoginRequestHandler: PacketHandler {

    public typealias Packet = MapleStory62.PlayerLoginRequest

    public let channel: MapleStory.Channel.ID

    public init(channel: MapleStory.Channel.ID) {
        self.channel = channel
    }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let (_, character, channel, _) = try await connection.playerLogin(
            character: packet.character,
            channel: self.channel
        )

        // Load character skills from database/registry
        try await CharacterSkillRegistry.shared.loadSkills(for: character.id, database: connection.database)

        // Load quest data
        try await character.loadQuestData(from: connection.database)

        // Load keymap
        try await KeymapRegistry.shared.loadKeymap(for: character.id, database: connection.database)

        let stats = WarpToMapNotification.CharacterStats(
            id: character.index,
            name: character.name,
            gender: character.gender,
            skinColor: character.skinColor,
            face: character.face,
            hair: character.hair,
            value0: 0,
            value1: 0,
            value2: 0,
            level: numericCast(character.level),
            job: character.job,
            str: character.str,
            dex: character.dex,
            int: character.int,
            luk: character.luk,
            hp: character.hp,
            maxHp: character.maxHp,
            mp: character.mp,
            maxMp: character.maxMp,
            ap: character.ap,
            sp: character.sp,
            exp: character.exp.rawValue,
            fame: character.fame,
            isMarried: character.isMarried ? 1 : 0,
            currentMap: character.currentMap,
            spawnPoint: character.spawnPoint,
            value3: 0
        )
        let info = WarpToMapNotification.CharacterInfo(
            channel: UInt32(channel.index),
            random0: UInt32.random(in: 0 ..< .max),
            random1: UInt32.random(in: 0 ..< .max),
            random2: UInt32.random(in: 0 ..< .max),
            stats: stats,
            buddyListSize: 20,
            meso: character.meso,
            equipSlots: 100,
            useSlots: 100,
            setupSlots: 100,
            etcSlots: 100,
            cashSlots: 100
        )
        try await connection.send(WarpToMapNotification.characterInfo(info))
        try await connection.sendMapMobs(for: character.currentMap)
    }
}
