//
//  FourthJob.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerFourthJob() {
        // 2081100 - Warrior 4th Job Advancer (Ludibrium)
        register(npc: 2081100) { ctx in
            let level = try await ctx.level
            guard level >= 120 else {
                try await ctx.sendNext("Sorry, but you have to be at least level 120 to make 4th Job Advancement.")
                return
            }
            let job = try await ctx.job
            try await ctx.sendNext("Hello, So you want 4th Job Advancement eh?")
            let (newJob, jobName): (Job, String)
            switch job {
            case .crusader:
                newJob = .hero; jobName = "Hero"
            case .whiteknight:
                newJob = .paladin; jobName = "Paladin"
            case .dragonknight:
                newJob = .darkknight; jobName = "Dark Knight"
            default:
                try await ctx.sendOk("I don't recognize your job for advancement.")
                return
            }
            let confirmed = try await ctx.sendYesNo("Congratulations on reaching such a high level. Do you want to become a #r\(jobName)#k?")
            guard confirmed else { return }
            try await ctx.changeJob(newJob)
            try await ctx.sendOk("There you go. Hope you enjoy it!")
        }

        // 2081200 - Magician 4th Job Advancer (Ludibrium)
        register(npc: 2081200) { ctx in
            let level = try await ctx.level
            guard level >= 120 else {
                try await ctx.sendNext("Sorry, but you have to be at least level 120 to make 4th Job Advancement.")
                return
            }
            let job = try await ctx.job
            try await ctx.sendNext("Hello, So you want 4th Job Advancement eh?")
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
            let confirmed = try await ctx.sendYesNo("Congratulations on reaching such a high level. Do you want to become a #r\(jobName)#k?")
            guard confirmed else { return }
            try await ctx.changeJob(newJob)
            try await ctx.sendOk("There you go. Hope you enjoy it!")
        }

        // 2081300 - Archer 4th Job Advancer (Ludibrium)
        register(npc: 2081300) { ctx in
            let level = try await ctx.level
            guard level >= 120 else {
                try await ctx.sendNext("Sorry, but you have to be at least level 120 to make 4th Job Advancement.")
                return
            }
            let job = try await ctx.job
            try await ctx.sendNext("Hello, So you want 4th Job Advancement eh?")
            let (newJob, jobName): (Job, String)
            switch job {
            case .hunter:
                newJob = .bowmaster; jobName = "Bowmaster"
            case .crossbowman:
                newJob = .marksman; jobName = "Marksman"
            default:
                try await ctx.sendOk("I don't recognize your job for advancement.")
                return
            }
            let confirmed = try await ctx.sendYesNo("Congratulations on reaching such a high level. Do you want to become a #r\(jobName)#k?")
            guard confirmed else { return }
            try await ctx.changeJob(newJob)
            try await ctx.sendOk("There you go. Hope you enjoy it!")
        }

        // 9200000 - Universal Job Advancer (all classes, all job levels)
        register(npc: 9200000) { ctx in
            let level = try await ctx.level
            let job = try await ctx.job
            try await ctx.sendNext("Hello, I'm in charge of Job Advancing.")

            if job == .beginner {
                if level < 8 {
                    try await ctx.sendNext("Sorry, but you have to be at least level 8 to use my services.")
                    return
                }
                if level < 10 {
                    let confirmed = try await ctx.sendYesNo("Congratulations on reaching such a high level. Would you like to make the #rFirst Job Advancement#k as a #rMagician#k?")
                    guard confirmed else { return }
                    guard try await ctx.int >= 20 else {
                        try await ctx.sendOk("You did not meet the minimum requirement of #r20 INT#k.")
                        return
                    }
                    try await ctx.changeJob(.magician)
                    try await ctx.sendOk("There you go. Hope you enjoy it. See you around in the future.")
                    return
                }
                let selection = try await ctx.sendSimple("Which would you like to be? #b\r\n#L0#Warrior#l\r\n#L1#Magician#l\r\n#L2#Bowman#l\r\n#L3#Thief#l\r\n#L4#Pirate#l#k")
                let (newJob, jobName, reqStat, reqVal): (Job, String, String, UInt16)
                switch selection {
                case 0: (newJob, jobName, reqStat, reqVal) = (.warrior, "Warrior", "STR", 35)
                case 1: (newJob, jobName, reqStat, reqVal) = (.magician, "Magician", "INT", 20)
                case 2: (newJob, jobName, reqStat, reqVal) = (.bowman, "Bowman", "DEX", 25)
                case 3: (newJob, jobName, reqStat, reqVal) = (.thief, "Thief", "DEX", 25)
                case 4: (newJob, jobName, reqStat, reqVal) = (.pirate, "Pirate", "DEX", 20)
                default: return
                }
                let confirmed = try await ctx.sendYesNo("Do you want to become a #r\(jobName)#k?")
                guard confirmed else { return }
                let stat: UInt16
                switch selection {
                case 0: stat = try await ctx.str
                case 1: stat = try await ctx.int
                default: stat = try await ctx.dex
                }
                guard stat >= reqVal else {
                    try await ctx.sendOk("You did not meet the minimum requirement of #r\(reqVal) \(reqStat)#k.")
                    return
                }
                try await ctx.changeJob(newJob)
                try await ctx.sendOk("There you go. Hope you enjoy it. See you around in the future.")
                return
            }

            // 2nd job advancement (level 30+)
            guard level >= 30 else {
                try await ctx.sendOk("Sorry, but you have to be at least level 30 to make the #rSecond Job Advancement#k.")
                return
            }

            let menuStr: String
            switch job {
            case .thief:
                menuStr = "Congratulations on reaching such a high level. Which would you like to be? #b\r\n#L0#Assassin#l\r\n#L1#Bandit#l#k"
            case .warrior:
                menuStr = "Congratulations on reaching such a high level. Which would you like to be? #b\r\n#L2#Fighter#l\r\n#L3#Page#l\r\n#L4#Spearman#l#k"
            case .magician:
                menuStr = "Congratulations on reaching such a high level. Which would you like to be? #b\r\n#L5#Ice/Lightning Wizard#l\r\n#L6#Fire/Poison Wizard#l\r\n#L7#Cleric#l#k"
            case .bowman:
                menuStr = "Congratulations on reaching such a high level. Which would you like to be? #b\r\n#L8#Hunter#l\r\n#L9#Crossbowman#l#k"
            case .pirate:
                menuStr = "Congratulations on reaching such a high level. Which would you like to be? #b\r\n#L10#Brawler#l\r\n#L11#Gunslinger#l#k"
            default:
                try await ctx.sendOk("Sorry, but you have already attained the highest level of your job's mastery.")
                return
            }
            let sel = try await ctx.sendSimple(menuStr)
            let (newJob2, jobName2): (Job, String)
            switch sel {
            case 0: (newJob2, jobName2) = (.assassin, "Assassin")
            case 1: (newJob2, jobName2) = (.bandit, "Bandit")
            case 2: (newJob2, jobName2) = (.fighter, "Fighter")
            case 3: (newJob2, jobName2) = (.page, "Page")
            case 4: (newJob2, jobName2) = (.spearman, "Spearman")
            case 5: (newJob2, jobName2) = (.ilWizard, "Ice/Lightning Wizard")
            case 6: (newJob2, jobName2) = (.fpWizard, "Fire/Poison Wizard")
            case 7: (newJob2, jobName2) = (.cleric, "Cleric")
            case 8: (newJob2, jobName2) = (.hunter, "Hunter")
            case 9: (newJob2, jobName2) = (.crossbowman, "Crossbowman")
            case 10: (newJob2, jobName2) = (.brawler, "Brawler")
            case 11: (newJob2, jobName2) = (.gunslinger, "Gunslinger")
            default: return
            }
            let confirmed2 = try await ctx.sendYesNo("Do you want to become a #r\(jobName2)#k?")
            guard confirmed2 else { return }
            try await ctx.changeJob(newJob2)
            try await ctx.sendOk("There you go. Hope you enjoy it. See you around in the future.")
        }

        // 2081400 - Thief 4th Job Advancer (Ludibrium)
        register(npc: 2081400) { ctx in
            let level = try await ctx.level
            guard level >= 120 else {
                try await ctx.sendNext("Sorry, but you have to be at least level 120 to make 4th Job Advancement.")
                return
            }
            let job = try await ctx.job
            try await ctx.sendNext("Hello, So you want 4th Job Advancement eh?")
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
            let confirmed = try await ctx.sendYesNo("Congratulations on reaching such a high level. Do you want to become a #r\(jobName)#k?")
            guard confirmed else { return }
            try await ctx.changeJob(newJob)
            try await ctx.sendOk("There you go. Hope you enjoy it!")
        }
    }
}
