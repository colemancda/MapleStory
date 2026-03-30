//
//  DamageSummonHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct DamageSummonHandler: PacketHandler {

    public typealias Packet = MapleStory83.DamageSummonRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let mapID = await connection.mapID else { return }

        try await connection.broadcast(
            DamageSummonNotification(
                characterID: character.index,
                summonObjectID: packet.objectID,
                unknown: packet.unkByte,
                damage: Int32(bitPattern: packet.damage),
                monsterIDFrom: packet.monsterIDFrom,
                unknown2: packet.stance
            ),
            map: mapID
        )
    }
}
