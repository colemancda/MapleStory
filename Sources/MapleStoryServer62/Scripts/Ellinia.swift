//
//  Ellinia.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerEllinia() {
        // 1032000 - Ellinia Regular Cab
        register(npc: 1032000) { ctx in
            let maps: [Map.ID] = [104000000, 102000000, 100000000, 103000000]
            let cost: [UInt32] = [1200, 1000, 1000, 1200]
            let costBeginner: [UInt32] = [120, 100, 100, 120]

            let isBeginner = try await ctx.job == .beginner
            try await ctx.sendNext(
                "How's it going? I drive the Regular Cab. If you want to go from town to town safely and fast, then ride our cab. We'll gladly take you to your destination with an affordable price."
            )

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

        // 1032003 - Shane (Ellinia Jump Quest entrance)
        register(npc: 1032003) { ctx in
            try await ctx.sendNext("Hello there! I guard this mysterious path. Those with great agility can try their luck inside.")
            try await ctx.sendNextPrev("There are two courses: JQ1 and JQ2. Each has a prize waiting at the end.")
            let confirmed = try await ctx.sendYesNo("Would you like to enter the Jump Quest?")
            guard confirmed else { return }
            try await ctx.warp(to: 101000100)
        }

        // 1032004 - Shane (warp back to Ellinia from JQ)
        register(npc: 1032004) { ctx in
            let confirmed = try await ctx.sendYesNo("Would you like to return to Ellinia?")
            guard confirmed else { return }
            try await ctx.warp(to: 101000000)
        }

        // 1032006 - Rene (storage)
        register(npc: 1032006) { ctx in
            try await ctx.sendStorage()
        }

        // 1032007 - Joel (Orbis ship ticket seller — Ellinia Station)
        register(npc: 1032007) { ctx in
            let cost: UInt32 = 5000
            let confirmed = try await ctx.sendYesNo(
                "Hello, I'm in charge of selling tickets for the ship ride to Orbis Station of Ossyria. The ride to Orbis takes off every 15 minutes, beginning on the hour, and it'll cost you #b\(cost) mesos#k. Are you sure you want to purchase #b#t4031045##k?"
            )
            guard confirmed else { return }
            guard try await ctx.meso >= cost else {
                try await ctx.sendOk("Are you sure you have #b\(cost) mesos#k? If so, then I urge you to check your etc. inventory, and see if it's full or not.")
                return
            }
            try await ctx.gainItem(4031045, 1)
            try await ctx.gainMeso(-Int32(cost))
        }

        // 1032008 - Cherry (Ellinia boat loader to Orbis)
        register(npc: 1032008) { ctx in
            let confirmed = try await ctx.sendYesNo("Do you wish to board the boat?")
            guard confirmed else { return }
            guard try await ctx.hasItem(4031045) else {
                try await ctx.sendOk("You do not have a ticket to get to Orbis.")
                return
            }
            try await ctx.gainItem(4031045, -1)
            try await ctx.warp(to: 101000301)
        }

        // 1032009 - Purin (on boat, can leave back to dock)
        register(npc: 1032009) { ctx in
            let confirmed = try await ctx.sendYesNo("Do you wish to leave the boat?")
            guard confirmed else { return }
            try await ctx.sendNext("Alright, see you next time. Take care.")
            try await ctx.warp(to: 101000300)
        }

        // 1032100 - Arwen the Fairy (crafting: Moon Rock, Star Rock, Black Feather)
        register(npc: 1032100) { ctx in
            let level = try await ctx.level
            guard level >= 40 else {
                try await ctx.sendOk("I can make rare, valuable items but unfortunately I can't make it for a stranger like you.")
                return
            }
            try await ctx.sendNext("Yeah... I am the master alchemist of the fairies. If you get me the materials, I'll make you a special item.")
            let selection = try await ctx.sendSimple("What do you want to make?#b\r\n#L0#Moon Rock#l\r\n#L1#Star Rock#l\r\n#L2#Black Feather#l")
            if selection == 0 {
                let confirmed = try await ctx.sendYesNo("So you want to make Moon Rock? To do that you need one refined plate of each: #bBronze#k, #bSteel#k, #bMithril#k, #bAdamantium#k, #bSilver#k, #bOrihalcon#k and #bGold#k. Throw in 10,000 mesos and I'll make it for you.")
                guard confirmed else { return }
                let hasAll = try await ctx.hasItem(4011000) && ctx.hasItem(4011001) && ctx.hasItem(4011002) && ctx.hasItem(4011003) && ctx.hasItem(4011004) && ctx.hasItem(4011005) && ctx.hasItem(4011006) && ctx.meso >= 10000
                guard hasAll else {
                    try await ctx.sendNext("Please check and see if you have the refined plates, one of each.")
                    return
                }
                try await ctx.gainMeso(-10000)
                for i: UInt32 in 4011000...4011006 { try await ctx.gainItem(i, -1) }
                try await ctx.gainItem(4011007, 1)
                try await ctx.sendNext("Ok here, take the Moon Rock. It's well-made. If you need my help down the road, feel free to come back.")
            } else if selection == 1 {
                let confirmed = try await ctx.sendYesNo("So you want to make the Star Rock? To do that you need one refined jewel of each: #bGarnet#k, #bAmethyst#k, #bAquaMarine#k, #bEmerald#k, #bOpal#k, #bSapphire#k, #bTopaz#k, #bDiamond#k and #bBlack Crystal#k. Throw in 15,000 mesos and I'll make it for you.")
                guard confirmed else { return }
                let hasAll = try await ctx.hasItem(4021000) && ctx.hasItem(4021001) && ctx.hasItem(4021002) && ctx.hasItem(4021003) && ctx.hasItem(4021004) && ctx.hasItem(4021005) && ctx.hasItem(4021006) && ctx.hasItem(4021007) && ctx.hasItem(4021008) && ctx.meso >= 15000
                guard hasAll else {
                    try await ctx.sendNext("Please check and see if you have the refined jewels, one of each.")
                    return
                }
                try await ctx.gainMeso(-15000)
                for i: UInt32 in 4021000...4021008 { try await ctx.gainItem(i, -1) }
                try await ctx.gainItem(4021009, 1)
                try await ctx.sendNext("Ok here, take the Star Rock. It's well-made. If you need my help down the road, feel free to come back.")
            } else if selection == 2 {
                let confirmed = try await ctx.sendYesNo("So you want to make Black Feather? To do that you need #b1 Flaming Feather#k, #b1 Moon Rock#k and #b1 Black Crystal#k. Throw in 30,000 mesos and I'll make it for you.")
                guard confirmed else { return }
                let hasAll = try await ctx.hasItem(4001006) && ctx.hasItem(4011007) && ctx.hasItem(4021008) && ctx.meso >= 30000
                guard hasAll else {
                    try await ctx.sendNext("Please check and see if you have the required materials.")
                    return
                }
                try await ctx.gainMeso(-30000)
                try await ctx.gainItem(4001006, -1)
                try await ctx.gainItem(4011007, -1)
                try await ctx.gainItem(4021008, -1)
                try await ctx.gainItem(4031042, 1)
                try await ctx.sendNext("Ok here, take the Black Feather. It's well-made. If you need my help down the road, feel free to come back.")
            }
        }

        // 1032005 - VIP Cab (Ant Tunnel from Ellinia)
        register(npc: 1032005) { ctx in
            let isBeginner = try await ctx.job == .beginner
            let price: UInt32 = isBeginner ? 1000 : 10000
            try await ctx.sendNext(
                "Hi there! This cab is for VIP customers only. Instead of just taking you to different towns like the regular cabs, we offer a much better service worthy of VIP class. It's a bit pricey, but... for only 10,000 mesos, we'll take you safely to the \r\n#bAnt Tunnel#k."
            )
            let prompt = isBeginner
                ? "We have a special 90% discount for beginners. The Ant Tunnel is located deep inside in the dungeon that's placed at the center of the Victoria Island, where the 24 Hr Mobile Store is. Would you like to go there for #b1,000 mesos#k?"
                : "The regular fee applies for all non-beginners. The Ant Tunnel is located deep inside in the dungeon that's placed at the center of the Victoria Island, where 24 Hr Mobile Store is. Would you like to go there for #b10,000 mesos#k?"
            let confirmed = try await ctx.sendYesNo(prompt)
            guard confirmed else {
                try await ctx.sendNext("This town also has a lot to offer. Find us if and when you feel the need to go to the Ant Tunnel Park.")
                return
            }
            guard try await ctx.meso >= price else {
                try await ctx.sendNext("It looks like you don't have enough mesos. Sorry but you won't be able to use this without it.")
                return
            }
            try await ctx.gainMeso(-Int32(price))
            try await ctx.warp(to: 105070001)
        }

        // 1032001 - Grendel the Really Old (Magician Job Advancement)
        register(npc: 1032001) { ctx in
            let job = try await ctx.job
            let level = try await ctx.level
            let int = try await ctx.int

            if job == .beginner {
                guard level > 7, int > 19 else {
                    try await ctx.sendOk("Train a bit more and I can show you the way of the #rMagician#k.")
                    return
                }
                try await ctx.sendNext("So you decided to become a #rMagician#k?")
                try await ctx.sendNextPrev("It is an important and final choice. You will not be able to turn back.")
                let confirmed = try await ctx.sendYesNo("Do you want to become a #rMagician#k?")
                guard confirmed else {
                    try await ctx.sendOk("Make up your mind and visit me again.")
                    return
                }
                try await ctx.changeJob(.magician)
                try await ctx.gainItem(1372005, 1)  // Wooden Wand
                try await ctx.sendOk("So be it! Now go, and go with pride.")
            } else if job == .magician, level >= 30 {
                try await ctx.sendNext("The progress you have made is astonishing.")
                try await ctx.sendNextPrev("You may be ready to take the next step as a #rFire/Poison Wizard#k, #rIce/Lightning Wizard#k or #rCleric#k.")
                let accepted = try await ctx.sendAcceptDecline("But first I must test your skills. Are you ready?")
                guard accepted else { return }
                // TODO: start 2nd job quest
                try await ctx.sendOk("Go see the #bJob Instructor#k near Ellinia. He will show you the way.")
            } else {
                try await ctx.sendOk("You have chosen wisely.")
            }
        }
    }
}
