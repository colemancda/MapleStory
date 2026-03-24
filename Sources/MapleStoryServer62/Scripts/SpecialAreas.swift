//
//  SpecialAreas.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerSpecialAreas() {
        // 9040007 - Inscription plate (Guild Quest hint)
        register(npc: 9040007) { ctx in
            try await ctx.sendOk("\"I fought the Rubian and I lost, and now I am imprisoned in the very gate that blocks my path, my body desecrated. However, my old clothing has holy power within. If you can return the clothing to my body, I should be able to open the gate. Please hurry! \r\n- Sharen III \r\n\r\nP.S. I know this is rather picky of me, but can you please return the clothes to my body #bbottom to top#k? Thank you for your services.\"")
        }

        // 9040011 - Guild Quest notice board
        register(npc: 9040011) { ctx in
            try await ctx.sendOk("<Notice> \r\n Are you part of a Guild that possesses an ample amount of courage and trust? Then take on the Guild Quest and challenge yourselves!\r\n\r\n#bTo Participate :#k\r\n1. The Guild must consist of at least 6 people!\r\n2. The leader of the Guild Quest must be a Master or a Jr. Master of the Guild!\r\n3. The Guild Quest may end early if the number of guild members participating falls below 6, or if the leader decides to end it early!")
        }

        // 9040012 - Guild Quest plaque
        register(npc: 9040012) { ctx in
            try await ctx.sendOk("The plaque translates as follows: \r\n\"The knights of Sharenian are proud warriors. Their Longinus Spears are both formidable weapons and the key to the castle's defense: By removing them from their platforms at the highest points of this hall, they block off the entrance from invaders.\"\r\n\r\nSomething seems to be etched in English on the side, barely readable: \r\n\"evil stole spears, chained up behind obstacles. return to top of towers. large spear, grab from higher up.\"\r\n...Obviously whoever figured it out didn't have much time to live. Poor guy.")
        }

        // 9120200 - Mushroom Shrine hideout → Showa Town warp
        register(npc: 9120200) { ctx in
            let confirmed = try await ctx.sendYesNo("Here you are, right in front of the hideout! What? You want to\r\nreturn to #m801000000#?")
            guard confirmed else {
                try await ctx.sendOk("If you want to return to #m801000000#, then talk to me.")
                return
            }
            try await ctx.warp(to: 801000000)
        }

        // 9120202 - Silent warp to Showa
        register(npc: 9120202) { ctx in
            try await ctx.warp(to: 801040004)
        }

        // 9120009 - Showa storage
        register(npc: 9120009) { ctx in
            try await ctx.sendStorage()
        }

        // 9201004 / 9201079 - Silent warp to Amoria
        register(npc: 9201004) { ctx in
            try await ctx.warp(to: 680000000)
        }

        register(npc: 9201079) { ctx in
            try await ctx.warp(to: 682000100)
        }

        // 9201042 - Amoria storage
        register(npc: 9201042) { ctx in
            try await ctx.sendStorage()
        }

        // 9201081 - NLC storage
        register(npc: 9201081) { ctx in
            try await ctx.sendStorage()
        }

        // 9220005 - Roodolph (Happyville warp)
        register(npc: 9220005) { ctx in
            let selection = try await ctx.sendSimple(
                "Do you want to go to the Extra Frosty Snow Zone or Happyville?\r\n#L0#I want to go to Extra Frosty Snow Zone!#l\r\n#L1#I want to go to Happyville!#l"
            )
            if selection == 0 {
                try await ctx.gainItem(1472063, 1)
                try await ctx.warp(to: 209080000)
            } else if selection == 1 {
                try await ctx.sendOk("Ok.")
                try await ctx.warp(to: 209000000)
            }
        }

        // 2060009 - Dolphin Taxi (to Herb Town)
        register(npc: 2060009) { ctx in
            let confirmed = try await ctx.sendYesNo("I drive the Dolphin Taxi! Do you want to go to Herb Town?")
            guard confirmed else { return }
            try await ctx.warp(to: 251000100)
        }

        // 2050016 - Boss warp NPC (to Free Market boss room)
        register(npc: 2050016) { ctx in
            let selection = try await ctx.sendSimple(
                "Do you want to go to Free Market 22 to fight some bosses?\r\n#L0#Yes#l\r\n#L1#No#l"
            )
            guard selection == 0 else { return }
            try await ctx.warp(to: 910000022)
        }

        // 2022004 - Tylus (El Nath PQ exit, warp to El Nath)
        register(npc: 2022004) { ctx in
            try await ctx.sendNext("Thank you for protecting me from all those #bCrimson Balrogs#k and #bLycanthropes#k!")
            try await ctx.warp(to: 211000001)
        }

        // 2080005 - Ludibrium storage
        register(npc: 2080005) { ctx in
            try await ctx.sendStorage()
        }

        // 2081009 - Moose (warp to Omega Sector)
        register(npc: 2081009) { ctx in
            try await ctx.warp(to: 221000300)
        }

        // 2090000 - Omega Sector storage
        register(npc: 2090000) { ctx in
            try await ctx.sendStorage()
        }

        // 2093003 - Korean Folk Town storage
        register(npc: 2093003) { ctx in
            try await ctx.sendStorage()
        }

        // 2100000 - Mu Lung storage
        register(npc: 2100000) { ctx in
            try await ctx.sendStorage()
        }

        // 2110000 - Herb Town storage
        register(npc: 2110000) { ctx in
            try await ctx.sendStorage()
        }

        // 2070000 - Aquarium storage
        register(npc: 2070000) { ctx in
            try await ctx.sendStorage()
        }

        // 2041008 - Leafre storage
        register(npc: 2041008) { ctx in
            try await ctx.sendStorage()
        }

        // 2050004 - Mu Lung storage
        register(npc: 2050004) { ctx in
            try await ctx.sendStorage()
        }

        // 2060008 - Herb Town storage (alternate)
        register(npc: 2060008) { ctx in
            try await ctx.sendStorage()
        }

        // 9120010 (NLC area storage variant - skip, complex)

        // 2080004 - Morph potion seller (Ludibrium)
        register(npc: 2080004) { ctx in
            let items: [UInt32] = [5300000, 5300001, 5300002, 2210003, 2210005]
            let cost: UInt32 = 500000
            try await ctx.sendNext("Morphs are special potions that transform you into many things.")
            var selStr = "So, what is your choice? Remember, it'll cost you #b500,000 mesos#k for each morph I sell."
            for i in 0 ..< items.count {
                selStr += "\r\n#b#L\(i)# #v\(items[i])# #t\(items[i])##l#k"
            }
            let selection = Int(try await ctx.sendSimple(selStr))
            guard selection < items.count else { return }
            guard try await ctx.meso >= cost else {
                try await ctx.sendOk("You do not have enough mesos.")
                return
            }
            try await ctx.gainMeso(-Int32(cost))
            try await ctx.gainItem(items[selection], 1)
        }

        // 2081005 - Cave of Life entrance (Ludibrium → Horntail dungeon)
        register(npc: 2081005) { ctx in
            let selection = try await ctx.sendSimple(
                "Welcome to Cave of Life - Entrance! Would you like to go inside and fight #rHorntail#k?\r\n#L1#I would like to buy 10 Unagi for 100,000 Mesos!#l\r\n#L2#No thanks, let me in now!#l"
            )
            if selection == 1 {
                guard try await ctx.meso >= 100000 else {
                    try await ctx.sendOk("Sorry, you don't have enough mesos to buy them!")
                    return
                }
                try await ctx.gainMeso(-100000)
                try await ctx.gainItem(2000005, 10)
                try await ctx.sendOk("Thank you for buying the potion. Use it as well!")
            } else if selection == 2 {
                guard try await ctx.level > 99 else {
                    try await ctx.sendOk("I'm sorry. You need to be at least level 100 or above to enter.")
                    return
                }
                try await ctx.warp(to: 240050000)
            }
        }
    }
}
