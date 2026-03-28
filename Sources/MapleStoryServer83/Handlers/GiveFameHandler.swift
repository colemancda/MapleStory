//
//  GiveFameHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct GiveFameHandler: PacketHandler {

    public typealias Packet = MapleStory83.GiveFameRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let fromCharacter = try await connection.character else { return }

        guard let targetCharacter = try await Character.fetch(
            packet.characterID,
            world: fromCharacter.world,
            in: connection.database
        ) else { return }

        guard targetCharacter.id != fromCharacter.id else { return }

        guard fromCharacter.level >= 15 else {
            try await connection.send(FameResponseNotification.error(2))
            return
        }

        let fameChange = Int32(packet.mode == 0 ? -1 : 1)

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

        var updatedTarget = targetCharacter
        let newFameRaw = Int32(targetCharacter.fame) + fameChange
        if abs(newFameRaw) < 30001 {
            updatedTarget.fame = UInt16(max(0, newFameRaw))
            try await connection.database.insert(updatedTarget)
        }

        let fameLog = FameLog(characterID: fromCharacter.id, characterIDTo: targetCharacter.id)
        try await connection.database.insert(fameLog)

        try await connection.send(FameResponseNotification.success(
            targetName: updatedTarget.name,
            mode: packet.mode,
            newFame: updatedTarget.fame
        ))
    }
}
