//
//  GachaponNPCs.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerGachaponNPCs() {
        let gachaponIDs: [UInt32] = [
            9100100, // Henesys
            9100101, // Ellinia
            9100102, // Perion
            9100103, // Kerning City
            9100104, // Sleepywood
            9100105, // Lith Harbor
            9100106, // Nautilus
            9100107, // Orbis
            9100108, // El Nath
            9100109, // Ludibrium
            9100110, // Aquarium
            9100111, // Mu Lung
            9270043, // Singapore
        ]

        for npcID in gachaponIDs {
            register(npc: npcID) { ctx in
                let ticket: UInt32 = 5220000
                guard try await ctx.hasItem(ticket) else {
                    try await ctx.sendOk("I am the Gachapon machine. Bring a #bGachapon Ticket#k to try your luck!")
                    return
                }
                try await ctx.sendOk("Gachapon is not yet available.")
            }
        }
    }
}
