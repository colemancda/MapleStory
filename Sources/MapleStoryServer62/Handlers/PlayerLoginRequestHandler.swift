//
//  PlayerLoginRequestHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

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
    }
}
