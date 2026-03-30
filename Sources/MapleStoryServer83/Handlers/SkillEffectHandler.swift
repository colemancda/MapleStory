//
//  SkillEffectHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct SkillEffectHandler: PacketHandler {

    public typealias Packet = MapleStory83.SkillEffectRequest

    public init() { }

    // Skills that are allowed to broadcast a visual effect.
    private static let allowedSkills: Set<UInt32> = [
        2111002,   // FP Mage: Explosion
        2121001,   // FP Arch Mage: Big Bang
        2221001,   // IL Arch Mage: Big Bang
        2321001,   // Bishop: Big Bang
        3121004,   // Bowmaster: Hurricane
        3221001,   // Marksman: Piercing Arrow
        4211001,   // Chief Bandit: Chakra
        5101004,   // Brawler: Corkscrew Blow
        5201002,   // Gunslinger: Grenade
        5221004,   // Corsair: Rapid Fire
        13111002,  // Wind Archer: Hurricane
        14111006,  // Night Walker: Poison Bomb
        15101003,  // Thunder Breaker: Corkscrew Blow
        1221001,   // Paladin: Monster Magnet
        1321001,   // Dark Knight: Monster Magnet
        1121001,   // Hero: Monster Magnet
        22151001,  // Evan: Fire Breath
        22121000,  // Evan: Ice Breath
    ]

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard Self.allowedSkills.contains(packet.skillID) else { return }
        guard let character = try await connection.character else { return }
        guard let mapID = await connection.mapID else { return }

        try await connection.broadcast(SkillEffectNotification(
            characterID: character.index,
            skillID: packet.skillID,
            level: packet.level,
            flags: packet.flags,
            speed: packet.speed
        ), map: mapID)
    }
}
