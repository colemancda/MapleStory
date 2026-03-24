//
//  LithHarbor.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerLithHarbor() {
        // 1002000 - Phil (Victoria Road taxi from Lith Harbour)
        register(npc: 1002000) { ctx in
            let maps: [Map.ID] = [102000000, 101000000, 100000000, 103000000]
            let mapNames = ["Perion", "Ellinia", "Henesys", "Kerning City"]
            let cost: [UInt32] = [1200, 1200, 800, 1000]
            let costBeginner: [UInt32] = [120, 120, 80, 100]

            try await ctx.sendNext("Hi, I'm Phil.")

            let isBeginner = try await ctx.job == .beginner
            var selStr = isBeginner
                ? "I can take you to various locations for just a small fee. Beginners will get a 90% discount on normal prices."
                : "I can take you to various locations for just a small fee."
            try await ctx.sendNextPrev(selStr)

            selStr = "Select your destination.#b"
            for i in 0 ..< maps.count {
                let price = isBeginner ? costBeginner[i] : cost[i]
                selStr += "\r\n#L\(i)##m\(maps[i].rawValue)# (\(price) meso)#l"
            }
            let selection = Int(try await ctx.sendSimple(selStr))
            guard selection < maps.count else { return }

            let price = isBeginner ? costBeginner[selection] : cost[selection]
            let confirmed = try await ctx.sendYesNo(
                "So you have nothing left to do here? Do you want to go to #m\(maps[selection].rawValue)#?"
            )
            guard confirmed else {
                try await ctx.sendOk("Alright, see you next time.")
                return
            }
            guard try await ctx.meso >= price else {
                try await ctx.sendOk("You do not have enough mesos.")
                return
            }
            try await ctx.gainMeso(-Int32(price))
            try await ctx.warp(to: maps[selection])
        }

        // 1002001 - Cody
        register(npc: 1002001) { ctx in
            try await ctx.sendOk("Hello. I'm Cody. Nice to meet you!")
        }

        // 1002002 - Pison (boat to Florina Beach)
        register(npc: 1002002) { ctx in
            try await ctx.sendNext("Hi, I drive a Boat.")
            try await ctx.sendNextPrev("I can take you to Florina Beach for just a small fee.")
            guard try await ctx.meso >= 1500 else {
                try await ctx.sendOk("You do not have enough mesos.")
                return
            }
            let confirmed = try await ctx.sendYesNo(
                "So you want to pay #b1500 mesos#k and leave for Florina Beach? Alright, then, but just be aware that you may be running into some monsters around there, too. Okay, would you like to head over to Florina Beach right now?"
            )
            guard confirmed else { return }
            try await ctx.gainMeso(-1500)
            try await ctx.warp(to: 110000000)
        }

        // 1002004 - VIP Cab (Ant Tunnel)
        register(npc: 1002004) { ctx in
            let isBeginner = try await ctx.job == .beginner
            let price: UInt32 = isBeginner ? 1000 : 10000
            try await ctx.sendNext(
                "Hi there! This cab is for VIP customers only. Instead of just taking you to different towns like the regular cabs, we offer a much better service worthy of VIP class. It's a bit pricey, but... for only 10,000 mesos, we'll take you safely to the \r\n#bAnt Tunnel#k."
            )
            let prompt = isBeginner
                ? "We have a special 90% discount for beginners. The Ant Tunnel is located deep inside in the dungeon that's placed at the center of the Victoria Island, where the 24 Hr Mobile Store is. Would you like to go there for #b1,000 mesos#k?"
                : "The regular fee applies for all non-beginners. The Ant Tunnel is located deep inside in the dungeon that's placed at the center of the Victoria Island, where 24 Hr Mobile Store is. Would you like to go there for #b10,000 mesos#k?"
            let confirmed = try await ctx.sendYesNo(prompt)
            guard confirmed else { return }
            guard try await ctx.meso >= price else {
                try await ctx.sendOk("It looks like you don't have enough mesos. Sorry but you won't be able to use this without it.")
                return
            }
            try await ctx.gainMeso(-Int32(price))
            try await ctx.warp(to: 105070001)
        }
    }
}
