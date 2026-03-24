//
//  Connection+NPC.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public extension MapleStoryServer.Connection
where ClientOpcode == MapleStory62.ClientOpcode, ServerOpcode == MapleStory62.ServerOpcode {

    /// Warp the player to a new map. Updates the DB, connection state, and sends the packet.
    func warp(to mapID: Map.ID, spawn: UInt8 = 0) async throws {
        guard var character = try await self.character else { return }
        character.currentMap = mapID
        character.spawnPoint = spawn
        try await database.insert(character)
        setMap(mapID)
        try await send(warpToMapNotification(character: character))
        try await sendMapMobs(for: mapID)
    }

    /// Build a `WarpToMapNotification` for the given character using current connection state.
    func warpToMapNotification(character: MapleStory.Character) -> WarpToMapNotification {
        let channelIdx = channelIndex ?? 0
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
            channel: UInt32(channelIdx),
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
        return .characterInfo(info)
    }

    /// Create an `NPCScriptContext` wired to this connection.
    func makeNPCContext(npcID: UInt32) -> NPCScriptContext<Socket, Database> {
        NPCScriptContext(
            npcID: npcID,
            connection: self,
            sendPacket: { [weak self] notification in
                try await self?.send(notification)
            }
        )
    }
}
