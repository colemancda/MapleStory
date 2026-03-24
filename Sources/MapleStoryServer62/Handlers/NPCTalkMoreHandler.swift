//
//  NPCTalkMoreHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct NPCTalkMoreHandler: PacketHandler {

    public typealias Packet = MapleStory62.NPCTalkMoreRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let ctx = await NPCConversationRegistry.shared.get(for: connection.address) else {
            return  // no active conversation
        }

        // action == 0xFF (-1 as signed byte) means the player closed the dialog
        if packet.action == 0xFF {
            await ctx.cancel()
            await NPCConversationRegistry.shared.remove(connection.address)
        } else {
            await ctx.resume(with: packet)
        }
    }
}
