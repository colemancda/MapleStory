//
//  DueyActionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles Duey (Package Delivery NPC) actions.
///
/// Duey is an NPC that allows players to send packages (items and mesos)
/// to other players, even across channels. This is one of the few ways
/// to transfer items between players who are not in the same channel.
///
/// # Duey System
///
/// Players interact with Duey to:
/// - **Send packages**: Send items/mesos to another player by name
/// - **Receive packages**: Pick up packages sent to them
/// - **Return packages**: Send back an unaccepted package
///
/// Packages cost mesos to send (delivery fee).
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Duey package delivery system is not yet implemented.
///
/// # TODO
///
/// - Handle send package action (deduct mesos, store package in DB)
/// - Handle receive package action (add items to inventory)
/// - Handle return package action
/// - Implement package expiration (packages expire after 30 days)
/// - Notify players when they receive a new package
public struct DueyActionHandler: PacketHandler {

    public typealias Packet = MapleStory62.DueyActionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Duey (delivery service) action — not yet implemented.
    }
}
