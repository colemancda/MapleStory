//
//  KerningCity.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerKerningCity() {
        // 1052016 - Kerning City Regular Cab
        register(npc: 1052016) { ctx in
            let maps: [Map.ID] = [104000000, 102000000, 101000000, 100000000]
            let cost: [UInt32] = [1000, 800, 1200, 1000]
            let costBeginner: [UInt32] = [100, 80, 120, 100]

            let isBeginner = try await ctx.job == .beginner
            try await ctx.sendNext("What's up? I drive the Regular Cab. If you want to go from town to town safely and fast, then ride our cab. We'll gladly take you to your destination with an affordable price.")

            var selStr = isBeginner
                ? "We have a special 90% discount for beginners. Choose your destination, for fees will change from place to place.#b"
                : "Choose your destination, for fees will change from place to place.#b"
            for i in 0 ..< maps.count {
                let price = isBeginner ? costBeginner[i] : cost[i]
                selStr += "\r\n#L\(i)##m\(maps[i].rawValue)# (\(price) mesos)#l"
            }
            let selection = Int(try await ctx.sendSimple(selStr))
            guard selection < maps.count else { return }

            let price = isBeginner ? costBeginner[selection] : cost[selection]
            let confirmed = try await ctx.sendYesNo(
                "You don't have anything else to do here, huh? Do you really want to go to #b#m\(maps[selection].rawValue)##k? It'll cost you #b\(price) mesos#k."
            )
            guard confirmed else {
                try await ctx.sendNext("There's a lot to see in this town, too. Come back and find us when you need to go to a different town.")
                return
            }
            guard try await ctx.meso >= price else {
                try await ctx.sendNext("You don't have enough mesos. Sorry to say this, but without them, you won't be able to ride the cab.")
                return
            }
            try await ctx.gainMeso(-Int32(price))
            try await ctx.warp(to: maps[selection])
        }

        // 1052001 - Dark Lord (Thief Job Advancement)
        register(npc: 1052001) { ctx in
            let job = try await ctx.job
            let level = try await ctx.level
            let dex = try await ctx.dex

            if job == .beginner {
                guard level >= 10, dex >= 25 else {
                    try await ctx.sendOk("Train a bit more and I can show you the way of the #rThief#k.")
                    return
                }
                try await ctx.sendNext("So you decided to become a #rThief#k?")
                try await ctx.sendNextPrev("It is an important and final choice. You will not be able to turn back.")
                let confirmed = try await ctx.sendYesNo("You know there is no other choice...")
                guard confirmed else {
                    try await ctx.sendOk("You know there is no other choice...")
                    return
                }
                try await ctx.changeJob(.thief)
                try await ctx.gainItem(1472000, 1)  // Garnier (Thief Claw)
                try await ctx.sendOk("So be it! Now go, and go with pride.")
            } else if job == .thief, level >= 30 {
                try await ctx.sendNext("The progress you have made is astonishing.")
                try await ctx.sendNextPrev("You may be ready to take the next step as a #rAssassin#k or #rBandit#k.")
                let accepted = try await ctx.sendAcceptDecline("But first I must test your skills. Are you ready?")
                guard accepted else { return }
                // TODO: start 2nd job quest
                try await ctx.sendOk("Go see the #bJob Instructor#k. He will show you the way.")
            } else {
                try await ctx.sendOk("You have chosen wisely.")
            }
        }
    }
}
