//
//  Sleepywood.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerSleepywood() {
        // 1061007 - Crumbling Stone (leave JQ area back to Sleepywood)
        register(npc: 1061007) { ctx in
            let confirmed = try await ctx.sendYesNo("Would you like to leave?")
            guard confirmed else { return }
            try await ctx.warp(to: 105040300)
        }

        // 1061100 - Hotel Receptionist (Sleepywood Hotel sauna)
        register(npc: 1061100) { ctx in
            let regCost: UInt32 = 499
            let vipCost: UInt32 = 999
            try await ctx.sendNext("Welcome. We're the Sleepywood Hotel. Our hotel works hard to serve you the best at all times. If you are tired and worn out from hunting, how about a relaxing stay at our hotel?")
            let selection = try await ctx.sendSimple(
                "We offer two kinds of rooms for our service. Please choose the one of your liking.\r\n#b#L0#Regular sauna (\(regCost) mesos per use)#l\r\n#L1#VIP sauna (\(vipCost) mesos per use)#l"
            )
            let (cost, dest): (UInt32, Map.ID)
            if selection == 0 {
                let confirmed = try await ctx.sendYesNo("You have chosen the regular sauna. Your HP and MP will recover fast and you can even purchase some items there. Are you sure you want to go in?")
                guard confirmed else { return }
                (cost, dest) = (regCost, 105040401)
            } else {
                let confirmed = try await ctx.sendYesNo("You've chosen the VIP sauna. Your HP and MP will recover even faster than that of the regular sauna and you can even find a special item in there. Are you sure you want to go in?")
                guard confirmed else { return }
                (cost, dest) = (vipCost, 105040402)
            }
            guard try await ctx.meso >= cost else {
                try await ctx.sendNext("I'm sorry. It looks like you don't have enough mesos. It will cost you at least \(cost) mesos to stay at our hotel.")
                return
            }
            try await ctx.gainMeso(-Int32(cost))
            try await ctx.warp(to: dest)
        }
    }
}
