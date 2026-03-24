//
//  CloseRangeAttackHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct CloseRangeAttackHandler: PacketHandler {

    public typealias Packet = MapleStory62.CloseRangeAttackRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Melee attack — damage calculation and monster HP not yet implemented.
    }
}
