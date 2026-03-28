//
//  SkillMacroHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct SkillMacroHandler: PacketHandler {

    public typealias Packet = MapleStory83.SkillMacroRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        let macros = packet.macros.enumerated().map { (index, macro) -> SkillMacro in
            SkillMacro(
                character: character.id,
                slot: UInt8(index),
                name: macro.name,
                shout: macro.shout,
                skill1: macro.skill1,
                skill2: macro.skill2,
                skill3: macro.skill3
            )
        }

        await SkillMacroRegistry.shared.saveMacros(macros, for: character.id)
        try await SkillMacroRegistry.shared.saveMacros(for: character.id, database: connection.database)
    }
}
