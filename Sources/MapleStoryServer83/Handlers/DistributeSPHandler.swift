//
//  DistributeSPHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct DistributeSPHandler: PacketHandler {

    public typealias Packet = MapleStory83.DistributeSPRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }
        guard character.sp > 0 else { return }

        guard let _ = await SkillDataCache.shared.skill(id: packet.skillID) else {
            return
        }

        let currentSkill = await CharacterSkillRegistry.shared.skill(packet.skillID, for: character.id)
        let currentLevel = currentSkill?.level ?? 0

        guard canLearnSkill(skillID: packet.skillID, job: character.job) else {
            return
        }

        let maxLevel = currentSkill?.masteryLevel ?? 10
        guard currentLevel < maxLevel else {
            return
        }

        let success = await CharacterSkillRegistry.shared.addSkillLevel(packet.skillID, for: character.id)
        guard success else {
            return
        }

        character.sp -= 1
        try await connection.database.insert(character)

        try await CharacterSkillRegistry.shared.saveSkills(for: character.id, database: connection.database)

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

    private func canLearnSkill(skillID: UInt32, job: Job) -> Bool {
        let jobPrefix = skillID / 10000

        switch job.type {
        case .beginner:
            return jobPrefix == 1000
        case .warrior:
            return jobPrefix == 1100 || jobPrefix == 1200 || jobPrefix == 1300 ||
                   jobPrefix == 1110 || jobPrefix == 1210 || jobPrefix == 1310 ||
                   jobPrefix == 1111 || jobPrefix == 1211 || jobPrefix == 1311 ||
                   jobPrefix == 1120 || jobPrefix == 1220 || jobPrefix == 1320
        case .magician:
            return jobPrefix == 2000 ||
                   jobPrefix == 2100 || jobPrefix == 2200 || jobPrefix == 2300 ||
                   jobPrefix == 2110 || jobPrefix == 2210 || jobPrefix == 2310 ||
                   jobPrefix == 2120 || jobPrefix == 2220 || jobPrefix == 2320
        case .bowman:
            return jobPrefix == 3000 || jobPrefix == 3100 || jobPrefix == 3200 ||
                   jobPrefix == 3110 || jobPrefix == 3210 ||
                   jobPrefix == 3120 || jobPrefix == 3220
        case .thief:
            return jobPrefix == 4000 || jobPrefix == 4100 || jobPrefix == 4200 ||
                   jobPrefix == 4110 || jobPrefix == 4210 ||
                   jobPrefix == 4120 || jobPrefix == 4220
        case .pirate:
            return jobPrefix == 5000 || jobPrefix == 5100 || jobPrefix == 5200 ||
                   jobPrefix == 5110 || jobPrefix == 5210 ||
                   jobPrefix == 5120 || jobPrefix == 5220
        default:
            return false
        }
    }
}
