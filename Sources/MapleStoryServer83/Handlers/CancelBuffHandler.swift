//
//  CancelBuffHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct CancelBuffHandler: PacketHandler {

    public typealias Packet = MapleStory83.CancelBuffRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        if isChanneledSkill(packet.skillID) {
            // Channeled skills (Big Bang, Hurricane, etc.) have no buff state to cancel —
            // just broadcast the visual cancellation to other players on the map.
            try await connection.broadcast(
                CancelSkillEffectNotification(characterID: character.index, skillID: packet.skillID),
                map: character.currentMap
            )
        } else {
            // Regular buffs: remove server-side state and notify the client.
            let removed = await connection.removeBuff(skillID: packet.skillID, from: character.id)
            guard removed else { return }
            try await connection.send(CancelBuffNotification(skillID: packet.skillID))
        }
    }

    // MARK: - Private

    /// Skills that are held/channeled rather than buffed — they broadcast a cancel
    /// animation to the map but have no buff state to remove server-side.
    private func isChanneledSkill(_ skillID: UInt32) -> Bool {
        switch skillID {
        case 2121001, // F/P Arch Mage: Big Bang
             2221001, // I/L Arch Mage: Big Bang
             2321001, // Bishop: Big Bang
             3121004, // Bowmaster: Hurricane
             3221001, // Marksman: Piercing Arrow
             5221004, // Corsair: Rapid Fire
             13111002: // Wind Archer: Hurricane
            return true
        default:
            return false
        }
    }
}
