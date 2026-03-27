//
//  SkillMacroHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles skill macro configuration (saving keybindings for skill combos).
///
/// Skill macros allow players to bind multiple skills to a single key,
/// creating custom skill combos. When the macro key is pressed, skills
/// are executed in sequence with configurable delays.
///
/// # Macro Configuration
///
/// - **Name**: Custom name for the macro
/// - **Skills**: Up to 3 skills in the macro chain
/// - **Delays**: Time between each skill activation
/// - **Key binding**: Which key triggers the macro
///
/// # Implementation
///
/// This handler saves skill macros to the SkillMacroRegistry.
public struct SkillMacroHandler: PacketHandler {

    public typealias Packet = MapleStory62.SkillMacroRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Convert packet macros to SkillMacro model
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

        // Save macros to registry
        await SkillMacroRegistry.shared.saveMacros(macros, for: character.id)

        // Save to database for persistence
        try await SkillMacroRegistry.shared.saveMacros(for: character.id, database: connection.database)

        print("[SkillMacro] Character \(character.index) saved \(macros.count) macros")
    }
}

// MARK: - Skill Macro Registry

/// Registry for storing player skill macro configurations
public actor SkillMacroRegistry {

    public static let shared = SkillMacroRegistry()

    private var macros: [Character.ID: [SkillMacro]] = [:]

    private init() {}

    /// Get macros for a character
    public func macros(for characterID: Character.ID) -> [SkillMacro] {
        return macros[characterID] ?? []
    }

    /// Save macros for a character
    public func saveMacros(_ macros: [SkillMacro], for characterID: Character.ID) {
        self.macros[characterID] = macros
    }

    /// Load macros from database
    public func loadMacros(for characterID: Character.ID, database: some ModelStorage) async throws {
        // TODO: Implement database loading
        // For now, initialize with empty macros
        macros[characterID] = []
    }

    /// Save macros to database
    public func saveMacros(for characterID: Character.ID, database: some ModelStorage) async throws {
        // TODO: Implement database saving
        // For now, just store in memory
    }
}