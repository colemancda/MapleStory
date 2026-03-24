//
//  NPCTalkHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct NPCTalkHandler: PacketHandler {

    public typealias Packet = MapleStory62.NPCTalkRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let npcID = packet.objectID

        guard let script = NPCScriptRegistry.shared.script(for: npcID) else {
            return  // no script registered for this NPC
        }

        // Cancel any in-progress conversation first
        if let existing = await NPCConversationRegistry.shared.get(for: connection.address) {
            await existing.cancel()
        }

        let address = connection.address
        let ctx = await connection.makeNPCContext(npcID: npcID)

        await NPCConversationRegistry.shared.set(ctx, for: address)

        Task {
            do {
                try await script(ctx)
            } catch is CancellationError {
                // player dismissed the dialog — normal flow
            } catch {
                // script error; conversation ends
            }
            await NPCConversationRegistry.shared.remove(address)
        }
    }
}
