//
//  NPCConversationRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Tracks the active NPC conversation for each connected player.
///
/// `NPCTalkHandler` creates and stores a context here when a player
/// clicks an NPC. `NPCTalkMoreHandler` retrieves it to deliver the
/// player's responses back to the suspended script.
public actor NPCConversationRegistry {

    public static let shared = NPCConversationRegistry()

    private var active = [MapleStoryAddress: NPCScriptContext]()

    private init() { }

    public func set(_ ctx: NPCScriptContext, for address: MapleStoryAddress) {
        active[address] = ctx
    }

    public func get(for address: MapleStoryAddress) -> NPCScriptContext? {
        active[address]
    }

    public func remove(_ address: MapleStoryAddress) {
        active[address] = nil
    }
}
