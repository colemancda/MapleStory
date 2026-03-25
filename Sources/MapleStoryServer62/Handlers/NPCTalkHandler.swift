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

/// Handles NPC (Non-Player Character) conversations.
///
/// # NPC System
///
/// NPCs are characters that players can interact with:
/// - **Quest NPCs**: Give quests and rewards
/// - **Shop NPCs**: Buy/sell items
/// - **Service NPCs**: Storage, hair salon, etc.
/// - **Story NPCs**: Advance game story
/// - **Decorative**: NPCs that just talk
///
/// # NPC Interaction
///
/// When a player talks to an NPC:
/// 1. Player presses NPC interaction key or clicks NPC
/// 2. Client sends NPC talk request with NPC ID
/// 3. Server looks up NPC script
/// 4. Server cancels any existing conversation
/// 5. Server creates NPC script context
/// 6. Server runs NPC script in background task
/// 7. Script sends dialog packets to client
/// 8. Client displays dialog UI
/// 9. Player can click buttons/enter text
/// 10. Script continues based on player choice
///
/// # NPC Scripts
///
/// NPC behavior is defined in scripts:
/// - Compiled/embedded in server code
/// - Registered in NPCScriptRegistry
/// - Script has access to:
///   - Player character data
///   - Player inventory
///   - Quest progress
///   - Map data
///
/// # Dialog Types
///
/// NPCs can show various dialog types:
///
/// **Simple Dialog (Say/Ask)**:
/// - Text box with OK/Cancel buttons
/// - Used for simple messages
///
/// **Selection Menu**:
/// - List of options to choose from
/// - Script branches based on choice
/// - Used for shop categories, quest choices
///
/// **Yes/No**:
/// - Simple yes/no confirmation
/// - Used for critical choices
///
/// **Text Input**:
/// - Player types text response
/// - Used for naming items, answering questions
///
/// **Number Input**:
/// - Player enters a number
/// - Used for quantities, prices
///
/// **Shop**:
/// - Opens shop interface
/// - Player can buy/sell items
///
/// # Conversation State
///
/// NPC conversations are tracked:
/// - Each player can have one active conversation
/// - Stored in NPCConversationRegistry
/// - Cancelled if player talks to another NPC
/// - Cancelled if player changes maps
/// - Persisted during dialog flow
///
/// # Quest NPCs
///
/// Quest-related NPC behavior:
/// - Check quest requirements (level, items, etc.)
/// - Show quest start dialog
/// - Accept quest from player
/// - Give quest items/rewards
/// - Update quest progress
/// - Complete quests
///
/// # Shop NPCs
///
/// Shop NPCs open shops:
/// - Recharge shop (throwing stars, bullets)
/// - Weapon shop
/// - Armor shop
/// - Potion shop
/// - Specialty shops (scrolls, ores, etc.)
/// - Each shop has item list and prices
///
/// # Service NPCs
///
/// /// NPCs provide services:
/// - **Storage Fredrick**: Item storage (costs mesos)
/// - **Hair Salon**: Change hair style/color
/// - **Plastic Surgery**: Change face
/// - **Plastic Surgery**: Change eye color
/// - **Dress Up**: Change skin color
/// - **Name Change**: Rename character (cash shop)
///
/// # Anti-Cheat
///
/// - **NPC validation**: Can't talk to invalid NPCs
/// - **Range check**: Must be near NPC to interact
/// - **Script validation**: Scripts can't crash server
/// - **Conversation cleanup**: Prevents conversation leaks
///
/// # Script Context
///
/// V62NPCScriptContext provides:
/// - Access to character data
/// - Access to inventory
/// - Access to quest data
/// - Ability to send packets
/// - Ability to check conditions
/// - Cancellation token for early exit
///
/// # Error Handling
///
/// If NPC script errors:
/// - Conversation ends gracefully
/// - Player can restart conversation
/// - Error logged for debugging
/// - No crash or data corruption
///
/// # Side Effects
///
/// - **Registry**: Stores conversation in NPCConversationRegistry
/// - **Cancels**: Any existing conversation for this player
/// - **Async**: Runs NPC script in background task
/// - **Packets**: Script sends dialog packets directly to client
/// - **No database**: Conversations are transient
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
