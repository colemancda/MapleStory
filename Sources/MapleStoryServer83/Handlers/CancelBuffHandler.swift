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
        guard let character = try await connection.character else {
            return
        }

        let removed = await connection.removeBuff(skillID: packet.skillID, from: character.id)

        guard removed else {
            return
        }

        try await connection.send(CancelBuffNotification(skillID: packet.skillID))
    }
}
