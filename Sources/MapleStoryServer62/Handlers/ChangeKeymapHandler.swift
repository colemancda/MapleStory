//
//  ChangeKeymapHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct ChangeKeymapHandler: PacketHandler {

    public typealias Packet = MapleStory62.ChangeKeymapRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Convert bindings to keymap entries
        let keymap = packet.bindings.map { binding in
            KeymapEntry(key: binding.key, type: binding.type, action: binding.action)
        }

        // Save keymap to registry
        await KeymapRegistry.shared.saveKeymap(keymap, for: character.id)

        // Save to database (for persistence across server restarts)
        try await KeymapRegistry.shared.saveKeymap(for: character.id, database: connection.database)
    }
}

// MARK: - Keymap Registry

/// Registry for storing player keymap configurations
public actor KeymapRegistry {

    public static let shared = KeymapRegistry()

    private var keymaps: [Character.ID: [KeymapEntry]] = [:]

    private init() {}

    /// Get keymap for a character
    public func keymap(for characterID: Character.ID) -> [KeymapEntry] {
        return keymaps[characterID] ?? []
    }

    /// Save keymap for a character
    public func saveKeymap(_ keymap: [KeymapEntry], for characterID: Character.ID) {
        keymaps[characterID] = keymap
    }

    /// Load keymap from database
    public func loadKeymap(for characterID: Character.ID, database: some ModelStorage) async throws {
        // TODO: Implement database loading
        // For now, initialize with empty keymap
        keymaps[characterID] = []
    }

    /// Save keymap to database
    public func saveKeymap(for characterID: Character.ID, database: some ModelStorage) async throws {
        // TODO: Implement database saving
        // For now, just store in memory
    }
}

/// Keymap entry (key binding)
public struct KeymapEntry: Codable, Equatable, Hashable, Sendable {
    public let key: UInt32
    public let type: UInt8
    public let action: UInt32

    public init(key: UInt32, type: UInt8, action: UInt32) {
        self.key = key
        self.type = type
        self.action = action
    }
}
