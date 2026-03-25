//
//  GiveFameHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles fame requests between players.
///
/// # Fame System
///
/// Players can give +1 or -1 fame to other players on the same map.
///
/// Rules enforced:
/// - Player must be level 15 or higher
/// - Cannot fame themselves
/// - Can only give fame once every 24 hours (any target)
/// - Can only give fame to the same target once per calendar month
/// - Target fame is capped so that abs(fame + change) < 30001
///
/// # Response Packets
///
/// On success: `FameResponseNotification.success` sent to giver,
/// `FameResponseNotification.received` sent to receiver (if online).
///
/// On failure: `FameResponseNotification.error(status)` sent to giver.
public struct GiveFameHandler: PacketHandler {

    public typealias Packet = MapleStory62.GiveFameRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let fromCharacter = try await connection.character else { return }

        // Find the target character by their numeric index in the same world
        guard let targetCharacter = try await Character.fetch(
            packet.characterID,
            world: fromCharacter.world,
            in: connection.database
        ) else { return }

        // Cannot fame yourself
        guard targetCharacter.id != fromCharacter.id else { return }

        // Player must be level 15 or higher
        guard fromCharacter.level >= 15 else {
            try await connection.send(FameResponseNotification.error(2))
            return
        }

        let fameChange = Int32(packet.mode == 0 ? -1 : 1)

        // Check daily limit: player can only give fame once every 24 hours (to anyone)
        let cutoff24h = Date(timeIntervalSinceNow: -24 * 3600)
        let dailyPredicate: FetchRequest.Predicate = .compound(.and([
            FameLog.CodingKeys.characterID.compare(.equalTo, .attribute(.string(fromCharacter.id.uuidString))),
            FameLog.CodingKeys.timestamp.compare(.greaterThanOrEqualTo, .attribute(.date(cutoff24h)))
        ]))
        let recentLogs = try await connection.database.fetch(FameLog.self, predicate: dailyPredicate, fetchLimit: 1)
        if !recentLogs.isEmpty {
            try await connection.send(FameResponseNotification.error(3))
            return
        }

        // Check monthly limit: player can only give fame to the same target once per calendar month
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let monthlyPredicate: FetchRequest.Predicate = .compound(.and([
            FameLog.CodingKeys.characterID.compare(.equalTo, .attribute(.string(fromCharacter.id.uuidString))),
            FameLog.CodingKeys.characterIDTo.compare(.equalTo, .attribute(.string(targetCharacter.id.uuidString))),
            FameLog.CodingKeys.timestamp.compare(.greaterThanOrEqualTo, .attribute(.date(monthStart)))
        ]))
        let monthlyLogs = try await connection.database.fetch(FameLog.self, predicate: monthlyPredicate, fetchLimit: 1)
        if !monthlyLogs.isEmpty {
            try await connection.send(FameResponseNotification.error(4))
            return
        }

        // Apply fame to target if within bounds
        var updatedTarget = targetCharacter
        let newFameRaw = Int32(targetCharacter.fame) + fameChange
        if abs(newFameRaw) < 30001 {
            updatedTarget.fame = UInt16(max(0, newFameRaw))
            try await connection.database.insert(updatedTarget)
        }

        // Record the fame transaction in the database
        let fameLog = FameLog(
            characterID: fromCharacter.id,
            characterIDTo: targetCharacter.id
        )
        try await connection.database.insert(fameLog)

        // Notify the giver of success
        try await connection.send(FameResponseNotification.success(
            targetName: updatedTarget.name,
            mode: packet.mode,
            newFame: updatedTarget.fame
        ))
    }
}
