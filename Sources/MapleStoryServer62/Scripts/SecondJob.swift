//
//  SecondJob.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerSecondJob() {
        // 1072000 - Warrior Job Instructor (sends to warrior test map)
        register(npc: 1072000) { ctx in
            try await ctx.sendNext("Oh, isn't this a letter from #bDances with Balrog#k?")
            try await ctx.sendNextPrev("So you want to prove your skills? Very well...")
            try await ctx.sendOk("You will have to collect me #b30 #t4031013##k. Good luck.")
            try await ctx.warp(to: 108000300)
        }

        // 1072001 - Magician Job Instructor
        register(npc: 1072001) { ctx in
            try await ctx.sendNext("Oh, isn't this a letter from #bGrendel the Really Old#k?")
            try await ctx.sendNextPrev("So you want to prove your skills? Very well...")
            try await ctx.sendOk("You will have to collect me #b30 #t4031013##k. Good luck.")
            try await ctx.warp(to: 108000200)
        }

        // 1072002 - Bowman Job Instructor
        register(npc: 1072002) { ctx in
            try await ctx.sendNext("Oh, isn't this a letter from #bAthena#k?")
            try await ctx.sendNextPrev("So you want to prove your skills? Very well...")
            try await ctx.sendOk("You will have to collect me #b30 #t4031013##k. Good luck.")
            try await ctx.warp(to: 108000100)
        }

        // 1072003 - Thief Job Instructor
        register(npc: 1072003) { ctx in
            try await ctx.sendNext("Oh, isn't this a letter from the #bDark Lord#k?")
            try await ctx.sendNextPrev("So you want to prove your skills? Very well...")
            try await ctx.sendOk("You will have to collect me #b30 #t4031013##k. Good luck.")
            try await ctx.warp(to: 108000400)
        }

        // 1072004 - Warrior test NPC (Rocky Mountain)
        register(npc: 1072004) { ctx in
            try await ctx.sendOk("You're a true hero! Take this and Dances with Balrog will acknowledge you.")
            try await ctx.warp(to: 102020300)
        }

        // 1072005 - Exit instructor after Magician test
        register(npc: 1072005) { ctx in
            try await ctx.sendOk("You're a true hero! Take this and Grendel the Really Old will acknowledge you.")
            try await ctx.warp(to: 101020000)
        }

        // 1072006 - Exit instructor after Bowman test
        register(npc: 1072006) { ctx in
            try await ctx.sendOk("You're a true hero! Take this and Athena will acknowledge you.")
            try await ctx.warp(to: 106010000)
        }

        // 1072007 - Exit instructor after Thief test
        register(npc: 1072007) { ctx in
            try await ctx.sendOk("You're a true hero! Take this and the Dark Lord will acknowledge you.")
            try await ctx.warp(to: 102040000)
        }
    }
}
