//
//  Nautilus.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerNautilus() {
        // 1090000 - Olaf (Pirate Job Advancement)
        register(npc: 1090000) { ctx in
            let job = try await ctx.job
            let level = try await ctx.level
            let dex = try await ctx.dex

            if job == .beginner {
                guard level >= 10, dex >= 25 else {
                    try await ctx.sendOk("Train a bit more and I can show you the way of the #rPirate#k.")
                    return
                }
                try await ctx.sendNext("So you decided to become a #rPirate#k?")
                try await ctx.sendNextPrev("It is an important and final choice. You will not be able to turn back.")
                let confirmed = try await ctx.sendYesNo("Do you want to become a #rPirate#k?")
                guard confirmed else {
                    try await ctx.sendOk("Come back once you have thought about it some more.")
                    return
                }
                try await ctx.changeJob(.pirate)
                try await ctx.sendOk("So be it! Now go with pride.")
            } else if job == .pirate, level >= 30 {
                try await ctx.sendNext("The progress you have made is astonishing.")
                try await ctx.sendNextPrev("You are now ready to take the next step as a #rGunslinger#k or #rBrawler#k.")
                let selection = try await ctx.sendSimple("What do you want to become?#b\r\n#L0#Gunslinger#l\r\n#L1#Brawler#l#k")
                let newJob: Job = selection == 0 ? .gunslinger : .brawler
                let jobName = selection == 0 ? "Gunslinger" : "Brawler"
                let confirmed = try await ctx.sendYesNo("Do you want to become a #r\(jobName)#k?")
                guard confirmed else {
                    try await ctx.sendOk("Come back once you have thought about it some more.")
                    return
                }
                try await ctx.changeJob(newJob)
                try await ctx.sendOk("Congratulations, you are now a \(jobName).")
            } else {
                try await ctx.sendOk("Please let me down...")
            }
        }

        // 1091004 - Nautilus storage
        register(npc: 1091004) { ctx in
            try await ctx.sendStorage()
        }
    }
}
