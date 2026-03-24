//
//  ThirdJob.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerThirdJob() {
        // 2020008 - Tylus (El Nath: Warrior 3rd Job Advancer)
        register(npc: 2020008) { ctx in
            let level = try await ctx.level
            let job = try await ctx.job
            guard job == .fighter || job == .page || job == .spearman else {
                try await ctx.sendOk("May #rOdin#k be with you!")
                return
            }
            guard level >= 70 else {
                try await ctx.sendOk("Your time has yet to come...")
                return
            }
            let (newJob, jobName): (Job, String)
            switch job {
            case .fighter:
                newJob = .crusader; jobName = "Crusader"
            case .page:
                newJob = .whiteknight; jobName = "White Knight"
            case .spearman:
                newJob = .dragonknight; jobName = "Dragon Knight"
            default:
                try await ctx.sendOk("I don't recognize your job for advancement.")
                return
            }
            let confirmed = try await ctx.sendYesNo("I knew this day would come eventually.\r\n\r\nAre you ready to become a #r\(jobName)#k?")
            guard confirmed else { return }
            try await ctx.changeJob(newJob)
            try await ctx.sendOk("You are now a #b\(jobName)#k.\r\n\r\nNow go, with pride!")
        }

        // 2020009 - Robeira (El Nath: Magician 3rd Job Advancer)
        register(npc: 2020009) { ctx in
            let level = try await ctx.level
            let job = try await ctx.job
            guard job == .fpWizard || job == .ilWizard || job == .cleric else {
                try await ctx.sendOk("May #rOdin#k be with you!")
                return
            }
            guard level >= 70 else {
                try await ctx.sendOk("Your time has yet to come...")
                return
            }
            let (newJob, jobName): (Job, String)
            switch job {
            case .fpWizard:
                newJob = .fpMage; jobName = "Fire/Poison Mage"
            case .ilWizard:
                newJob = .ilMage; jobName = "Ice/Lightning Mage"
            case .cleric:
                newJob = .priest; jobName = "Priest"
            default:
                try await ctx.sendOk("I don't recognize your job for advancement.")
                return
            }
            let confirmed = try await ctx.sendYesNo("#rBy Odin's beard!#k You are a strong one. Are you ready to become a #r\(jobName)#k?")
            guard confirmed else { return }
            try await ctx.changeJob(newJob)
            try await ctx.sendOk("You are now a #b\(jobName)#k. May #rOdin#k be with you!")
        }

        // 2020010 - Rene (El Nath: Bowman 3rd Job Advancer)
        register(npc: 2020010) { ctx in
            let level = try await ctx.level
            let job = try await ctx.job
            guard job == .hunter || job == .crossbowman else {
                try await ctx.sendOk("May #rOdin#k be with you!")
                return
            }
            guard level >= 70 else {
                try await ctx.sendOk("Your time has yet to come...")
                return
            }
            let (newJob, jobName): (Job, String)
            switch job {
            case .hunter:
                newJob = .ranger; jobName = "Ranger"
            case .crossbowman:
                newJob = .sniper; jobName = "Sniper"
            default:
                try await ctx.sendOk("I don't recognize your job for advancement.")
                return
            }
            let confirmed = try await ctx.sendYesNo("#rBy Odin's beard!#k You are a strong one. Are you ready to become a #r\(jobName)#k?")
            guard confirmed else { return }
            try await ctx.changeJob(newJob)
            try await ctx.sendOk("You are now a #b\(jobName)#k. May #rOdin#k be with you!")
        }

        // 2020011 - Arec (El Nath: Thief 3rd Job Advancer)
        register(npc: 2020011) { ctx in
            let level = try await ctx.level
            let job = try await ctx.job
            guard job == .assassin || job == .bandit else {
                try await ctx.sendOk("May #rOdin#k be with you!")
                return
            }
            guard level >= 70 else {
                try await ctx.sendOk("Your time has yet to come...")
                return
            }
            let (newJob, jobName): (Job, String)
            switch job {
            case .assassin:
                newJob = .hermit; jobName = "Hermit"
            case .bandit:
                newJob = .chiefbandit; jobName = "Chief Bandit"
            default:
                try await ctx.sendOk("I don't recognize your job for advancement.")
                return
            }
            let confirmed = try await ctx.sendYesNo("#rBy Odin's beard!#k You are a strong one. Are you ready to become a #r\(jobName)#k?")
            guard confirmed else { return }
            try await ctx.changeJob(newJob)
            try await ctx.sendOk("You are now a #b\(jobName)#k. May #rOdin#k be with you!")
        }
    }
}
