//
//  NoteActionHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct NoteActionHandler: PacketHandler {

    public typealias Packet = MapleStory83.NoteActionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // In-game note (mail) read / delete — not yet implemented.
    }
}
