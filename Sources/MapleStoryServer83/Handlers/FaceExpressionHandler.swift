//
//  FaceExpressionHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct FaceExpressionHandler: PacketHandler {

    public typealias Packet = MapleStory83.FaceExpressionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        try await connection.broadcast(FacialExpressionNotification(
            characterID: character.index,
            expression: packet.emote
        ), map: character.currentMap)
    }
}
