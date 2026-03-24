//
//  NPCConversationRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStoryServer
import Socket
import CoreModel
import MongoSwift
import MongoDBModel

/// Type alias for v62-specific NPC context (used in conversation registry)
public typealias V62NPCScriptContext = NPCScriptContext<MapleStorySocketIPv4TCP, MongoModelStorage>

/// Tracks the active NPC conversation for each connected player.
///
/// `NPCTalkHandler` creates and stores a context here when a player
/// clicks an NPC. `NPCTalkMoreHandler` retrieves it to deliver the
/// player's responses back to the suspended script.
public actor NPCConversationRegistry {

    public static let shared = NPCConversationRegistry()

    private var active = [MapleStoryAddress: V62NPCScriptContext]()

    private init() { }

    public func set(_ ctx: V62NPCScriptContext, for address: MapleStoryAddress) {
        active[address] = ctx
    }

    public func get(for address: MapleStoryAddress) -> V62NPCScriptContext? {
        active[address]
    }

    public func remove(_ address: MapleStoryAddress) {
        active[address] = nil
    }

    /// Get the NPC ID for a player's active conversation.
    public func getNPC(for address: MapleStoryAddress) -> UInt32? {
        active[address]?.npcID
    }
}
