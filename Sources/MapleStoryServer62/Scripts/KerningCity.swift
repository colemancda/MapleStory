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
