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
import Socket
import MongoSwift
import MongoDBModel

public struct NPCTalkHandler: PacketHandler {

    public typealias Packet = MapleStory62.NPCTalkRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let npcID = packet.objectID

        // Use the v62-specific registry (cast required since registry uses concrete types)
        guard let script = NPCScriptRegistryShared.script(for: npcID) else {
            return  // no script registered for this NPC
        }

        // Cancel any in-progress conversation first
        if let existing = await NPCConversationRegistry.shared.get(for: connection.address) {
            await existing.cancel()
        }

        let address = connection.address
        let ctx = await connection.makeNPCContext(npcID: npcID)

        // Cast to concrete type for registry
        let v62Ctx = ctx as! V62NPCScriptContext
        await NPCConversationRegistry.shared.set(v62Ctx, for: address)

        Task {
            do {
                try await script(v62Ctx)
            } catch is CancellationError {
                // player dismissed the dialog — normal flow
            } catch {
                // script error; conversation ends
            }
            await NPCConversationRegistry.shared.remove(address)
        }
    }
}
