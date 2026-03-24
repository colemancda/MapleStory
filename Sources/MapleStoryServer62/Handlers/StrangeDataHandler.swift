//
//  StrangeDataHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct StrangeDataHandler: PacketHandler {

    public typealias Packet = MapleStory62.ClientErrorRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // No response; log for diagnostics
        NSLog("Strange data from \(connection.address): error=\(packet.error) v0=\(packet.value0) v1=\(packet.value1)")
    }
}
