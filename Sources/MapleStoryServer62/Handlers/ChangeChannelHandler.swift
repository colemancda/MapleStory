//
//  ChangeChannelHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles requests to change to a different channel within the same world.
///
/// # Channel System
///
/// Each world is divided into multiple channels (instances of the game world).
/// Players can change channels to:
/// - Avoid crowded maps
/// - Find party members in other channels
/// - Access less competitive training spots
/// - Join friends in different channels
///
/// # Channel Change Flow
///
/// 1. Player selects a channel from the channel list
/// 2. Client sends channel change request
/// 3. Server validates channel exists and is not full
/// 4. Server validates channel address is valid
/// 5. Server sends channel change notification with new address
/// 6. Client disconnects and reconnects to new channel
///
/// # Validation
///
/// The handler validates:
/// - Player is logged in to a world
/// - Target channel exists in the same world
/// - Target channel is not full
/// - Channel address is valid IPv4 address
///
/// # Error Conditions
///
/// | Situation | Message |
/// |-----------|---------|
/// | Invalid channel | "Invalid channel." |
/// | Channel full | "That channel is full." |
/// | Invalid address | "Channel address is invalid." |
///
/// # Channel Transfer
///
/// The response contains:
/// - Response code (1 = success)
/// - Channel server address (IPv4)
/// - Channel server port
///
/// # Preserved State
///
/// When changing channels, the following are preserved:
/// - Character data (level, stats, equipment, etc.)
/// - Inventory items
/// - Quest progress
/// - Buddy list
/// - Guild membership
/// - Party membership (if party is cross-channel)
///
/// The following may be reset:
/// - Current map position (player appears in same map on new channel)
/// - Buffs (may need to be reapplied)
/// - Party chat (may need to rejoin)
///
/// # Response
///
/// Sends `ChangeChannelNotification` with:
/// - Channel server IP address (4 bytes)
/// - Channel server port number
/// - Response code indicating success/failure
public struct ChangeChannelHandler: PacketHandler {

    public typealias Packet = MapleStory62.ChangeChannelRequest

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
