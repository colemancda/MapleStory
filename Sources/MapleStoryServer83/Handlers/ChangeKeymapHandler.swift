//
//  ChangeKeymapHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct ChangeKeymapHandler: PacketHandler {

    public typealias Packet = MapleStory83.ChangeKeymapRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        let keymap = packet.bindings.map { binding in
            KeymapEntry(key: binding.key, type: binding.type, action: binding.action)
        }

        await connection.saveKeymap(keymap, for: character.id)
        try await connection.persistKeymap(for: character.id)
    }
}
