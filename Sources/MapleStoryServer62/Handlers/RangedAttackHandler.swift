//
//  RangedAttackHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct RangedAttackHandler: PacketHandler {

    public typealias Packet = MapleStory62.RangedAttackRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        try await connection.processAttack(targets: packet.targets, mapID: character.currentMap)
    }
}
