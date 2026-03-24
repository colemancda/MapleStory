//
//  Perion.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerPerion() {
        // 1022000 - Dances with Balrog (Warrior Job Advancement)
        register(npc: 1022000) { ctx in
            let job = try await ctx.job
            let level = try await ctx.level
            let str = try await ctx.str

            if job == .beginner {
                guard level >= 10, str >= 35 else {
                    try await ctx.sendOk("Train a bit more and I can show you the way of the #rWarrior#k.")
                    return
                }
                try await ctx.sendNext("So you decided to become a #rWarrior#k?")
                try await ctx.sendNextPrev("It is an important and final choice. You will not be able to turn back.")
                let confirmed = try await ctx.sendYesNo("Do you want to become a #rWarrior#k?")
                guard confirmed else {
                    try await ctx.sendOk("Make up your mind and visit me again.")
                    return
                }
                try await ctx.changeJob(.warrior)
                try await ctx.gainItem(1402001, 1)  // Sword
                try await ctx.sendOk("So be it! Now go, and go with pride.")
            } else if job == .warrior, level >= 30 {
                try await ctx.sendNext("The progress you have made is astonishing.")
                try await ctx.sendNextPrev("You may be ready to take the next step as a #rFighter#k, #rPage#k or #rSpearman#k.")
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
