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

/// Handles player responses during NPC conversations (dialog continuation).
///
/// When an NPC presents a dialog with multiple choices (OK/Cancel, Yes/No,
/// numbered options, etc.), the player's response is sent via this packet.
/// The server routes the response to the NPC's script engine for processing.
///
/// # Dialog Response Types
///
/// - **0x00 - OK / Next**: Player pressed OK or Next
/// - **0x01 - Cancel / Back**: Player pressed Cancel or Back
/// - **0x02 - Selection**: Player selected a numbered menu option
/// - **0x03 - Text input**: Player entered text
/// - **0x04 - Number input**: Player entered a number
///
/// # NPC Script Flow
///
/// 1. Player talks to NPC → NPCTalkHandler runs script start
/// 2. Script sends dialog packet → player sees dialog
/// 3. Player responds → NPCTalkMoreHandler passes response to script
/// 4. Script continues based on response
/// 5. Steps 2-4 repeat until script ends
///
/// # Script Engine
///
/// NPC conversations are driven by Lua scripts or Swift NPC script implementations
/// that define the full conversation flow for each NPC.
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
