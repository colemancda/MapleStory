//
//  MapleIsland.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerMapleIsland() {
        // 2101 - NPC taking you out of the Mushroom Town training camp
        register(npc: 2101) { ctx in
            let confirmed = try await ctx.sendYesNo("Are you done with your training? If you wish, I will send you out from this training camp.")
            guard confirmed else {
                try await ctx.sendOk("Haven't you finished the training program yet? If you want to leave this place, please do not hesitate to tell me.")
                return
            }
            try await ctx.sendNext("Then, I will send you out from here. Good job.")
            try await ctx.warp(to: 40000)
        }

        // 2101000 - Simple dialog NPC (Korean folk town)
        register(npc: 2101000) { ctx in
            try await ctx.sendOk("Just dancing well is not enough for me. I want to do a marvelous brilliant dance!")
        }

        // 2101001 - Simple dialog NPC
        register(npc: 2101001) { ctx in
            try await ctx.sendNext("I miss my sister... She's always working at the palace as the servant and I only get to see her on Sundays. The King and Queen are so selfish.")
        }

        // 9101001 - Peter (Mushroom Town Training Camp exit)
        register(npc: 9101001) { ctx in
            try await ctx.sendNext("You have finished all your trainings. Good job. You seem to be ready to start with the journey right away! Good, I will let you move on to the next place.")
            try await ctx.sendNextPrev("But remember, once you get out of here, you will enter a village full with monsters. Well then, good bye!")
            try await ctx.gainExp(3)
            try await ctx.warp(to: 40000)
        }
    }
}
