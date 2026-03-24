//
//  DistributeSPHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct DistributeSPHandler: PacketHandler {

    public typealias Packet = MapleStory62.DistributeSPRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }
        guard character.sp > 0 else { return }

        // Decrement the SP pool. Skill leveling requires a skill system (Phase 3);
        // for now just consume the point and notify the client.
        character.sp -= 1
        try await connection.database.insert(character)

        let notification = UpdateStatsNotification(
            announce: true,
            stats: .availableSP,
            skin: nil, face: nil, hair: nil, level: nil, job: nil,
            str: nil, dex: nil, int: nil, luk: nil,
            hp: nil, maxHp: nil, mp: nil, maxMp: nil,
            ap: nil, sp: character.sp,
            exp: nil, fame: nil, meso: nil
        )
        try await connection.send(notification)
    }
}
