//
//  BeautyNPCs.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

// MARK: - Registration

extension NPCScriptRegistry {

    func registerBeautyNPCs() {

        // 1012104 - Brittany (Henesys Hair Salon) - random hair
        register(npc: 1012104) { ctx in
            let gender = try await ctx.gender
            let hair = try await ctx.hair
            let currentColor = hair.rawValue % 10

            let maleStyles: [UInt32] = [30030, 30020, 30000, 30050, 30120, 30110, 30100, 30060, 30070, 30090, 30080, 30040, 30010, 30130, 30140, 30150, 30160, 30170, 30180, 30190, 30200, 30210]
            let femaleStyles: [UInt32] = [31040, 31010, 31060, 31050, 31000, 31030, 31090, 31070, 31080, 31020, 31100, 31110, 31120, 31130, 31140, 31150, 31160, 31170, 31180, 31190, 31200, 31210]

            let randomCoupon: UInt32 = 5150010
            let colorCoupon: UInt32 = 5151000

            let hasRandomCoupon = try await ctx.hasItem(randomCoupon)
            let hasColorCoupon = try await ctx.hasItem(colorCoupon)

            guard hasRandomCoupon || hasColorCoupon else {
                try await ctx.sendOk("I'm Brittany, the hair stylist of Henesys. I can change your hairstyle, but you'll need a #bHair Coupon#k first.")
                return
            }

            let styles = gender == .male ? maleStyles : femaleStyles
            let newStyle = styles.randomElement()! * 10 + currentColor

            if hasRandomCoupon {
                let confirmed = try await ctx.sendYesNo("I'll give you a random new hairstyle for one #bHair Coupon#k. Ready?")
                guard confirmed else { return }
                try await ctx.gainItem(randomCoupon, -1)
                try await ctx.changeHair(newStyle)
                try await ctx.sendOk("Enjoy your new look!")
            } else {
                let confirmed = try await ctx.sendYesNo("I'll dye your hair a random new color for one #bHair Color Coupon#k. Ready?")
                guard confirmed else { return }
                let newColor = UInt32.random(in: 0...7)
                let dyedHair = (hair.rawValue / 10) * 10 + newColor
                try await ctx.gainItem(colorCoupon, -1)
                try await ctx.changeHair(dyedHair)
                try await ctx.sendOk("Enjoy your new hair color!")
            }
        }

        // 1052100 - Don Giovanni (Kerning City Hair Salon) - VIP hair
        register(npc: 1052100) { ctx in
            let gender = try await ctx.gender
            let hair = try await ctx.hair
            let currentColor = hair.rawValue % 10

            let maleStyles: [UInt32] = [30030, 30050, 30120, 30110, 30100, 30060, 30070, 30090, 30140, 30150, 30160, 30170]
            let femaleStyles: [UInt32] = [31040, 31060, 31050, 31090, 31070, 31080, 31100, 31110, 31120, 31130, 31140, 31150]

            let vipCoupon: UInt32 = 5150003
            let colorCoupon: UInt32 = 5151003

            let hasVipCoupon = try await ctx.hasItem(vipCoupon)
            let hasColorCoupon = try await ctx.hasItem(colorCoupon)

            guard hasVipCoupon || hasColorCoupon else {
                try await ctx.sendOk("I'm Don Giovanni, the most renowned hair stylist in Kerning City. You'll need a #bVIP Hair Coupon#k or #bVIP Hair Color Coupon#k to use my services.")
                return
            }

            let styles = gender == .male ? maleStyles : femaleStyles

            if hasVipCoupon {
                var menuStr = "Choose your new hairstyle:"
                for (i, style) in styles.enumerated() {
                    menuStr += "\r\n#L\(i)##v\(style * 10 + currentColor)# Style \(i + 1)#l"
                }
                let selection = try await ctx.sendSimple(menuStr)
                guard selection >= 0 && Int(selection) < styles.count else { return }
                let newStyle = styles[Int(selection)] * 10 + currentColor
                let confirmed = try await ctx.sendYesNo("Are you sure you want this hairstyle?")
                guard confirmed else { return }
                try await ctx.gainItem(vipCoupon, -1)
                try await ctx.changeHair(newStyle)
                try await ctx.sendOk("Excellent choice! Enjoy your new look!")
            } else {
                var menuStr = "Choose your new hair color:"
                for i in 0...7 {
                    menuStr += "\r\n#L\(i)#Color \(i + 1)#l"
                }
                let selection = try await ctx.sendSimple(menuStr)
                guard selection >= 0 && selection <= 7 else { return }
                let newColor = UInt32(selection)
                let dyedHair = (hair.rawValue / 10) * 10 + newColor
                let confirmed = try await ctx.sendYesNo("Are you sure you want this hair color?")
                guard confirmed else { return }
                try await ctx.gainItem(colorCoupon, -1)
                try await ctx.changeHair(dyedHair)
                try await ctx.sendOk("Looking sharp! Enjoy your new color!")
            }
        }

        // 1052101 - Andre (Kerning City Hair Salon) - random hair
        register(npc: 1052101) { ctx in
            let gender = try await ctx.gender
            let hair = try await ctx.hair
            let currentColor = hair.rawValue % 10

            let maleStyles: [UInt32] = [30030, 30020, 30000, 30050, 30120, 30110, 30100, 30060, 30070, 30090, 30080, 30040]
            let femaleStyles: [UInt32] = [31040, 31010, 31060, 31050, 31000, 31030, 31090, 31070, 31080, 31020]

            let randomCoupon: UInt32 = 5150011
            let colorCoupon: UInt32 = 5151002

            let hasRandomCoupon = try await ctx.hasItem(randomCoupon)
            let hasColorCoupon = try await ctx.hasItem(colorCoupon)

            guard hasRandomCoupon || hasColorCoupon else {
                try await ctx.sendOk("I'm Andre. I can give you a new hairstyle, but you'll need a #bHair Coupon#k first.")
                return
            }

            let styles = gender == .male ? maleStyles : femaleStyles
            let newStyle = styles.randomElement()! * 10 + currentColor

            if hasRandomCoupon {
                let confirmed = try await ctx.sendYesNo("I'll give you a random new hairstyle for one #bHair Coupon#k. Ready?")
                guard confirmed else { return }
                try await ctx.gainItem(randomCoupon, -1)
                try await ctx.changeHair(newStyle)
                try await ctx.sendOk("Enjoy your new look!")
            } else {
                let confirmed = try await ctx.sendYesNo("I'll dye your hair a random new color for one #bHair Color Coupon#k. Ready?")
                guard confirmed else { return }
                let newColor = UInt32.random(in: 0...7)
                let dyedHair = (hair.rawValue / 10) * 10 + newColor
                try await ctx.gainItem(colorCoupon, -1)
                try await ctx.changeHair(dyedHair)
                try await ctx.sendOk("Enjoy your new hair color!")
            }
        }

        // 9270025 - Xan (Singapore skin care)
        register(npc: 9270025) { ctx in
            let skinCoupon: UInt32 = 5153010
            guard try await ctx.hasItem(skinCoupon) else {
                try await ctx.sendOk("Hi, I'm Xan. I can change your skin tone, but you'll need a #bSkin-Care Coupon#k first.")
                return
            }
            let skinColors: [UInt32] = [0, 1, 2, 3, 4, 5]
            let skinNames = ["Light", "Tanned", "Dark", "Pale", "Blue", "Green"]
            var menuStr = "Choose a skin tone:"
            for (i, name) in skinNames.enumerated() {
                menuStr += "\r\n#L\(i)#\(name)#l"
            }
            let selection = try await ctx.sendSimple(menuStr)
            guard selection >= 0 && Int(selection) < skinColors.count else { return }
            let confirmed = try await ctx.sendYesNo("Are you sure you want to change to this skin tone?")
            guard confirmed else { return }
            try await ctx.gainItem(skinCoupon, -1)
            try await ctx.changeSkin(skinColors[Int(selection)])
            try await ctx.sendOk("Enjoy your new look!")
        }
    }
}
