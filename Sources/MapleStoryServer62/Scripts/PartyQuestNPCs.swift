//
//  PartyQuestNPCs.swift
//
//
//  Created by Alsey Coleman Mill on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerPartyQuestNPCs() {
        let notAvailable = "Party quests are not yet available."

        // 1052006-1052011 - Kerning City PQ (KPQ) entrance NPCs
        for npcID: UInt32 in [1052006, 1052007, 1052008, 1052009, 1052010, 1052011] {
            register(npc: npcID) { ctx in
                try await ctx.sendOk(notAvailable)
            }
        }

        // 1012112-1012114 - Henesys PQ (HPQ) entrance NPCs
        for npcID: UInt32 in [1012112, 1012113, 1012114] {
            register(npc: npcID) { ctx in
                try await ctx.sendOk(notAvailable)
            }
        }

        // 2013000 - Orbis PQ (OPQ) entrance NPC
        register(npc: 2013000) { ctx in
            try await ctx.sendOk(notAvailable)
        }
    }
}
