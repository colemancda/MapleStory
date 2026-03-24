//
//  Singapore.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerSingapore() {
        // 9270017 - Xinga (Pilot, Singapore → Kerning City)
        register(npc: 9270017) { ctx in
            let cost: UInt32 = 20000
            try await ctx.sendNext("Hi, I'm a ticket gate.")
            try await ctx.sendNextPrev("I can take you back to Kerning City for just a small fee.")
            guard try await ctx.meso >= cost else {
                try await ctx.sendOk("You do not have enough mesos.")
                return
            }
            let confirmed = try await ctx.sendYesNo(
                "The ride to Kerning City of Victoria Island will cost you #b\(cost) mesos#k. Are you sure you want to return to #bKerning City#k?"
            )
            guard confirmed else {
                try await ctx.sendOk("Alright bye. I already reminded you that there is no refund right?")
                return
            }
            try await ctx.gainMeso(-Int32(cost))
            try await ctx.warp(to: 103000100)
        }

        // 9270033 - Silent warp to Singapore airport
        register(npc: 9270033) { ctx in
            try await ctx.warp(to: 541010110)
        }

        // 9270038 - Shalon (Singapore Airport → Kerning City)
        register(npc: 9270038) { ctx in
            let selection = try await ctx.sendSimple(
                "Hello there. I am Shalon from Singapore Airport. I can assist you in getting back to Kerning City in no time. How can I help you?\r\n#L0##bI would like to go back to Kerning City.#k#l"
            )
            guard selection == 0 else { return }
            try await ctx.warp(to: 103000000)
        }

        // 9270041 - Irene (Kerning City → Singapore)
        register(npc: 9270041) { ctx in
            let selection = try await ctx.sendSimple(
                "Hello there~ I am Irene from Kerning City. I can assist you in getting to Singapore in no time. How can I help you?\r\n#L0##bI would like to go to Singapore.#k#l"
            )
            guard selection == 0 else { return }
            try await ctx.warp(to: 540010000)
        }

        // 9270042 - Singapore storage
        register(npc: 9270042) { ctx in
            try await ctx.sendStorage()
        }
    }
}
