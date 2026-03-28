//
//  ChangeChannelHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct ChangeChannelHandler: PacketHandler {

    public typealias Packet = MapleStory83.ChangeChannelRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let world = try await connection.world else { return }
        guard let targetChannel = try await Channel.fetch(packet.channel, world: world.id, in: connection.database) else {
            try await connection.send(ServerMessageNotification.notice(message: "Invalid channel."))
            return
        }
        guard targetChannel.status != .full else {
            try await connection.send(ServerMessageNotification.notice(message: "That channel is full."))
            return
        }

        let address = targetChannel.address.address
            .split(separator: ".")
            .compactMap { UInt8($0) }
        guard address.count == 4 else {
            try await connection.send(ServerMessageNotification.notice(message: "Channel address is invalid."))
            return
        }

        try await connection.send(ChangeChannelNotification(
            responseCode: 1,
            address: address,
            port: targetChannel.address.port
        ))
    }
}
