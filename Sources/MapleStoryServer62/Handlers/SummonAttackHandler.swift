//
//  SummonAttackHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct SummonAttackHandler: PacketHandler {

    public typealias Packet = MapleStory62.SummonAttackRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Broadcast summon attack to other players on the same map
        guard let mapID = await connection.mapID else { return }

        try await connection.broadcast(SummonAttackNotification(
            characterID: character.index,
            objectID: packet.objectID,
            numAttacked: packet.numAttacked
        ), map: mapID)

        // TODO: Implement damage calculation
        // In a full implementation, we would:
        // 1. Calculate damage based on summon skill and character stats
        // 2. Apply damage to the attacked monsters
        // 3. Handle monster death and experience gain
    }
}

// MARK: - Summon Attack Notification

/// Sent when a summon attacks monsters
public struct SummonAttackNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .summonAttack }

    /// Character ID who owns the summon
    public let characterID: UInt32

    /// Summon object ID
    public let objectID: UInt32

    /// Number of monsters attacked
    public let numAttacked: UInt8

    public init(characterID: UInt32, objectID: UInt32, numAttacked: UInt8) {
        self.characterID = characterID
        self.objectID = objectID
        self.numAttacked = numAttacked
    }
}
