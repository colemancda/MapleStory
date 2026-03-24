//
//  Ossyria.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerOssyria() {
        // 2001001-2001004 - Christmas Tree warp NPCs
        for npcID: UInt32 in [2001001, 2001002, 2001003, 2001004] {
            register(npc: npcID) { ctx in
                let confirmed = try await ctx.sendYesNo("We have a beautiful christmas tree.\r\nDo you want to see/decorate it?")
                guard confirmed else { return }
                try await ctx.warp(to: 209000001)
            }
        }

        // 2003 - AP Stat Reset NPC
        register(npc: 2003) { ctx in
            let confirmed = try await ctx.sendYesNo("Do you want a free stat reset?")
            guard confirmed else { return }
            try await ctx.resetStats()
            try await ctx.sendOk("Your stats have been reset!")
        }

        // 2010006 - Orbis storage
        register(npc: 2010006) { ctx in
            try await ctx.sendStorage()
        }

        // 9000010 - Silent warp NPC (to event map 109050000)
        register(npc: 9000010) { ctx in
            try await ctx.warp(to: 109050000)
        }
    }
}
