//
//  RefiningNPCs.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerRefiningNPCs() {
        // 1002100 - Jane the Alchemist (Lith Harbor)
        register(npc: 1002100) { ctx in
            try await ctx.sendOk("It's you... I've been making items as usual. Refining is not yet available.")
        }

        // 1022003 - Mr. Thunder (Perion - mineral/jewel refining)
        register(npc: 1022003) { ctx in
            try await ctx.sendOk("You've heard about my forging skills? I'd be glad to process some of your ores... but that service is not yet available.")
        }

        // 1022004 - Francois (Perion - jewel refining)
        register(npc: 1022004) { ctx in
            try await ctx.sendOk("Looking for some jewel work? Refining is not yet available.")
        }

        // 1052002 - Vicious (Kerning City - refining)
        register(npc: 1052002) { ctx in
            try await ctx.sendOk("Need some work done? Refining is not yet available.")
        }

        // 1052003 - Lana (Kerning City - refining)
        register(npc: 1052003) { ctx in
            try await ctx.sendOk("I do all kinds of work here. Refining is not yet available.")
        }
    }
}
