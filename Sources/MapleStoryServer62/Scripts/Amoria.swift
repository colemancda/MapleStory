//
//  Amoria.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerAmoria() {
        // 9201023 - Nana (K) — Proof of Love: Horned Mushroom Caps
        register(npc: 9201023) { ctx in
            guard try await ctx.hasItem(4000015) else {
                try await ctx.sendNext("Hey, you look like you need proofs of love? I can get them for you.")
                try await ctx.sendNext("All you have to do is bring me 40 #bHorned Mushroom Caps#k.")
                return
            }
            try await ctx.sendNext("Wow, you were quick! Here's the proof of love...")
            try await ctx.gainItem(4000015, -40)
            try await ctx.gainItem(4031367, 1)
        }

        // 9201024 - Nana (E) — Proof of Love: Soft Feathers
        register(npc: 9201024) { ctx in
            guard try await ctx.hasItem(4003005) else {
                try await ctx.sendNext("Hey, you look like you need proofs of love? I can get them for you.")
                try await ctx.sendNext("All you have to do is bring me 20 #bSoft Feathers#k.")
                return
            }
            try await ctx.sendNext("Wow, you were quick! Here's the proof of love...")
            try await ctx.gainItem(4003005, -20)
            try await ctx.gainItem(4031368, 1)
        }

        // 9201025 - Nana (O) — Proof of Love: Jr. Sentinel Pieces
        register(npc: 9201025) { ctx in
            guard try await ctx.hasItem(4000083) else {
                try await ctx.sendNext("Hey, you look like you need proofs of love? I can get them for you.")
                try await ctx.sendNext("All you have to do is bring me 20 #bJr. Sentinel Pieces#k.")
                return
            }
            try await ctx.sendNext("Wow, you were quick! Here's the proof of love...")
            try await ctx.gainItem(4000083, -20)
            try await ctx.gainItem(4031369, 1)
        }

        // 9201026 - Nana (L) — Proof of Love: Teddy Cotton
        register(npc: 9201026) { ctx in
            guard try await ctx.hasItem(4000106) else {
                try await ctx.sendNext("Hey, you look like you need proofs of love? I can get them for you.")
                try await ctx.sendNext("All you have to do is bring me 30 #bTeddy Cotton#k.")
                return
            }
            try await ctx.sendNext("Wow, you were quick! Here's the proof of love...")
            try await ctx.gainItem(4000106, -30)
            try await ctx.gainItem(4031370, 1)
        }

        // 9201027 - Nana (P) — Proof of Love: Firewood
        register(npc: 9201027) { ctx in
            guard try await ctx.hasItem(4000018) else {
                try await ctx.sendNext("Hey, you look like you need proofs of love? I can get them for you.")
                try await ctx.sendNext("All you have to do is bring me 40 #bFirewood#k.")
                return
            }
            try await ctx.sendNext("Wow, you were quick! Here's the proof of love...")
            try await ctx.gainItem(4000018, -40)
            try await ctx.gainItem(4031371, 1)
        }
    }
}
