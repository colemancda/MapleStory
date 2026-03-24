//
//  EventNPCs.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerEventNPCs() {
        // 9000000 - Paul (Southperry event NPC)
        register(npc: 9000000) { ctx in
            try await ctx.sendNext(
                "Hey, I'm #bPaul#k, if you're not busy and all ... then can I hang out with you? I heard there are people gathering up around here for an #revent#k but I don't want to go there by myself ... Well, do you want to go check it out with me?"
            )
            let selection = try await ctx.sendSimple(
                "Huh? What kind of an event? Well, that's...\r\n#L0##e1.#n#b What kind of an event is it?#k#l\r\n#L1##e2.#n#b Explain the event game to me.#k#l\r\n#L2##e3.#n#b Alright, let's go!#k#l"
            )
            switch selection {
            case 0:
                try await ctx.sendOk("All this month, MapleStory Global is celebrating its 3rd anniversary! The GM's will be holding surprise GM Events throughout the event, so stay on your toes and make sure to participate in at least one of the events for great prizes!")
            case 1:
                try await ctx.sendOk("There are many games for this event. It will help you a lot to know how to play the game before you play it.")
            case 2:
                try await ctx.sendOk("Either the event has not been started, or you have already participated. Please try again later!")
            default:
                break
            }
        }

        // 9000001 - Jean (Lith Harbour event NPC)
        register(npc: 9000001) { ctx in
            try await ctx.sendNext("Hey, I'm #bJean#k. I am waiting for my brother #bPaul#k. He is supposed to be here by now...")
            try await ctx.sendNextPrev("Hmm... What should I do? The event will start, soon... Many people went to participate in the event, so we better be hurry...")
            let selection = try await ctx.sendSimple(
                "Hey... Why don't you go with me? I think my brother will come with other people.\r\n#L0##e1.#n#b What kind of an event is it?#k#l\r\n#L1##e2.#n#b Explain the event game to me.#k#l\r\n#L2##e3.#n#b Alright, let's go!#k#l"
            )
            switch selection {
            case 0:
                try await ctx.sendOk("All this month, MapleStory Global is celebrating its 3rd anniversary! The GM's will be holding surprise GM Events throughout the event, so stay on your toes and make sure to participate in at least one of the events for great prizes!")
            case 1:
                try await ctx.sendOk("There are many games for this event. It will help you a lot to know how to play the game before you play it.")
            case 2:
                try await ctx.sendOk("Either the event has not been started, or you have already participated. Please try again later!")
            default:
                break
            }
        }

        // 9000002 - Silent warp NPC (various maps)
        register(npc: 9000002) { ctx in
            try await ctx.warp(to: 100000000)
        }

        // 9001000 - Coke Bear (Coke World warp)
        register(npc: 9001000) { ctx in
            let selection = try await ctx.sendSimple(
                " Do you want to go to the Coke World or get out of the Coke World ?\r\n#L0#I want to go to the Coke World !#l\r\n#L1#I want to get out of the Coke World :(#l"
            )
            if selection == 0 {
                try await ctx.warp(to: 211040300)
            } else if selection == 1 {
                try await ctx.warp(to: 910000000)
            }
        }

        // 9001002 - PvP warp NPC
        register(npc: 9001002) { ctx in
            let confirmed = try await ctx.sendYesNo("Do you want to go to the PvP map and fight with your friends?")
            guard confirmed else { return }
            try await ctx.sendNext("Alright, good luck in there!")
            try await ctx.warp(to: 800020400)
        }
    }
}
