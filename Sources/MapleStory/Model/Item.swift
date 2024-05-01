//
//  Item.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct Item: Equatable, Hashable, Codable, Sendable {
    
    public let id: ID
    
    public var name: String
    
    public var descriptionText: String
}

public extension Item {
    
    /// MapleStory Item Identifier
    struct ID: RawRepresentable, Equatable, Hashable, Codable, Sendable {
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Item.ID: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Item.ID: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue.description
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - Constants

public extension Item.ID {
    
    // Potion
    static var whitePotion: Item.ID     { 2000002 }
    static var bluePotion: Item.ID      { 2000003 }
    static var orangePotion: Item.ID    { 2000001 }
    static var manaElixir: Item.ID      { 2000006 }
    
    // Misc
    static var pendantOfTheSpirit: Item.ID { 1122017 }
    static var heartShapedChocolate: Item.ID { 5110000 }
    static var happyBirthday: Item.ID { 2022153 }
    static var fishingChair: Item.ID { 3011000 }
    static var miniGameBase: Item.ID { 4080000 }
    static var matchCards: Item.ID { 4080100 }
    static var magicalMitten: Item.ID { 1472063 }
    static var rpsCertificateBase: Item.ID { 4031332 }
    static var goldenMapleLeaf: Item.ID { 4000313 }
    static var perfectPitch: Item.ID { 4310000 }
    static var magicRock: Item.ID { 4006000 }
    static var goldenChickenEffect: Item.ID { 4290000 }
    static var bummerEffect: Item.ID { 4290001 }
    static var arpqShield: Item.ID { 2022269 }
    static var roaringTigerMessenger: Item.ID { 5390006 }
    // HP/MP recovery
    static var sorcerersPotion: Item.ID { 2022337 }
    static var russellonsPills: Item.ID { 2022198 }
    // Environment
    static var redBeanPorridge: Item.ID { 2022001 }
    static var softWhiteBun: Item.ID { 2022186 }
    static var airBubble: Item.ID { 2022040 }
    // Chair
    static var relaxer: Item.ID { 3010000 }
    // Throwing star
    static var subiThrowingStars: Item.ID { 2070000 }
    static var hwabiThrowingStars: Item.ID { 2070007 }
    static var balancedFury: Item.ID { 2070018 }
    static var crystalIlbiThrowingStars: Item.ID { 2070016 }
    static var devilRainThrowingStar: Item.ID { 2070014 }
    // Bullet
    static var bullet: Item.ID { 2330000 }
    static var blazeCapsule: Item.ID { 2331000 }
    static var glazeCapsule: Item.ID { 2332000 }
    // Starter
    static var beginnersGuide: Item.ID { 4161001 }
    static var legendsGuide: Item.ID { 4161048 }
    static var noblesseGuide: Item.ID { 4161047 }
    // Warrior
    static var redHwarangShirt: Item.ID { 1040021 }
    static var blackMartialArtsPants: Item.ID { 1060016 }
    static var mithrilBattleGrieves: Item.ID { 1072039 }
    static var gladius: Item.ID { 1302008 }
    static var mithrilPoleArm: Item.ID { 1442001 }
    static var mithrilMaul: Item.ID { 1422001 }
    static var firemansAxe: Item.ID { 1312005 }
    static var darkEngrit: Item.ID { 1051010 }
    // Bowman
    static var greenHuntersArmor: Item.ID { 1040067 }
    static var greenHuntressArmor: Item.ID { 1041054 }
    static var greenHuntersPants: Item.ID { 1060056 }
    static var greenHuntressPants: Item.ID { 1061050 }
    static var greenHunterBoots: Item.ID { 1072081 }
    static var ryden: Item.ID { 1452005 }
    static var mountainCrossbow: Item.ID { 1462000 }
    // Magician
    static var blueWizardRobe: Item.ID { 1050003 }
    static var purpleFairyTop: Item.ID { 1041041 }
    static var purpleFairySkirt: Item.ID { 1061034 }
    static var redMagicshoes: Item.ID { 1072075 }
    static var mithrilWand: Item.ID { 1372003 }
    static var circleWindedStaff: Item.ID { 1382017 }
    // Thief
    static var darkBrownStealer: Item.ID { 1040057 }
    static var redSteal: Item.ID { 1041047 }
    static var darkBrownStealerPants: Item.ID { 1060043 }
    static var redStealPants: Item.ID { 1061043 }
    static var bronzeChainBoots: Item.ID { 1072032 }
    static var steelGuards: Item.ID { 1472008 }
    static var reefClaw: Item.ID { 1332012 }
    // Pirate
    static var brownPaulieBoots: Item.ID { 1072294 }
    static var primeHands: Item.ID { 1482004 }
    static var coldMind: Item.ID { 1492004 }
    static var brownPollard: Item.ID { 1052107 }
    // Three snails
    static var snailShell: Item.ID { 4000019 }
    static var blueSnailShell: Item.ID { 4000000 }
    static var redSnailShell: Item.ID { 4000016 }
    // Special scroll
    static var coldProtectionScroll: Item.ID { 2041058 }
    static var spikesScroll: Item.ID { 2040727 }
    static var vegasSpell10: Item.ID { 5610000 }
    static var vegasSpell60: Item.ID { 5610001 }
    static var chaosScroll60: Item.ID { 2049100 }
    static var liarTreeSap: Item.ID { 2049101 }
    static var mapleSyrup: Item.ID { 2049102 }
    static var whiteScroll: Item.ID { 2340000 }
    static var cleanSlate1: Item.ID { 2049000 }
    static var cleanSlate3: Item.ID { 2049001 }
    static var cleanSlate5: Item.ID { 2049002 }
    static var cleanSlate20: Item.ID { 2049003 }
    static var ringStr100Scroll: Item.ID { 2041100 }
    static var dragonStoneScroll: Item.ID { 2041200 }
    static var beltStr100Scroll: Item.ID { 2041300 }
    // Cure debuff
    static var allCurePotion: Item.ID { 2050004 }
    static var eyedrop: Item.ID { 2050001 }
    static var tonic: Item.ID { 2050002 }
    static var holyWater: Item.ID { 2050003 }
    static var antiBanishScroll: Item.ID { 2030100 }
    static var dojoPartyAllCure: Item.ID { 2022433 }
    static var carnivalPartyAllCure: Item.ID { 2022163 }
    static var whiteElixir: Item.ID { 2022544 }
    // Special effect
    static var pharaohsBlessing1: Item.ID { 2022585 }
    static var pharaohsBlessing2: Item.ID { 2022586 }
    static var pharaohsBlessing3: Item.ID { 2022587 }
    static var pharaohsBlessing4: Item.ID { 2022588 }
    // Evolve pet
    static var dragonPet: Item.ID { 5000028 }
    static var roboPet: Item.ID { 5000047 }
    // Pet equip
    static var mesoMagnet: Item.ID { 1812000 }
    static var itemPouch: Item.ID { 1812001 }
    static var itemIgnore: Item.ID { 1812007 }
    // Expirable pet
    static var petSnail: Item.ID { 5000054 }
    // Permanent pet
    static var permaPinkBean: Item.ID { 5000060 }
    static var permaKino: Item.ID { 5000100 }
    static var permaWhiteTiger: Item.ID { 5000101 }
    static var permaMiniYeti: Item.ID { 5000102 }
    // Maker
    static var basicMonsterCrystal1: Item.ID { 4260000 }
    static var basicMonsterCrystal2: Item.ID { 4260001 }
    static var basicMonsterCrystal3: Item.ID { 4260002 }
    static var intermediateMonsterCrystal1: Item.ID { 4260003 }
    static var intermediateMonsterCrystal2: Item.ID { 4260004 }
    static var intermediateMonsterCrystal3: Item.ID { 4260005 }
    static var advancedMonsterCrystal1: Item.ID { 4260006 }
    static var advancedMonsterCrystal2: Item.ID { 4260007 }
    static var advancedMonsterCrystal3: Item.ID { 4260008 }
    // NPC weather (PQ)
    static var npcWeatherGrowlie: Item.ID { 5120016 }
    // Safety charm
    static var safetyCharm: Item.ID { 5130000 }
    static var easterBasket: Item.ID { 4031283 }
    static var easterCharm: Item.ID { 4140903 }
    // Engagement box
    static var engagementBoxMoonstone: Item.ID { 2240000 }
    static var engagementBoxStar: Item.ID { 2240001 }
    static var engagementBoxGolden: Item.ID { 2240002 }
    static var engagementBoxSilver: Item.ID { 2240003 }
    static var emptyEngagementBoxMoonstone: Item.ID { 4031357 }
    static var engagementRingMoonstone: Item.ID { 4031358 }
    static var emptyEngagementBoxStar: Item.ID { 4031359 }
    static var engagementRingStar: Item.ID { 4031360 }
    static var emptyEngagementBoxGolden: Item.ID { 4031361 }
    static var engagementRingGolden: Item.ID { 4031362 }
    static var emptyEngagementBoxSilver: Item.ID { 4031363 }
    static var engagementRingSilver: Item.ID { 4031364 }
    // Medal
    static var noblesseMedal: Item.ID { 1142005 }
    static var warriorMedal: Item.ID { 1142006 }
    static var mageMedal: Item.ID { 1142007 }
    static var archerMedal: Item.ID { 1142008 }
    static var thiefMedal: Item.ID { 1142009 }
    static var pirateMedal: Item.ID { 1142010 }
    static var adventurersMedal: Item.ID { 1142011 }
    // World map
    static var worldMap: Item.ID { 4000038 }
    static var townMap: Item.ID { 4000039 }
    static var cashShopMap: Item.ID { 4000040 }
    // Drop voucher
    static var dropVoucher1: Item.ID { 4000519 }
    static var dropVoucher2: Item.ID { 4000520 }
    static var dropVoucher3: Item.ID { 4000521 }
    static var dropVoucher4: Item.ID { 4000522 }
    static var dropVoucher5: Item.ID { 4000523 }
    static var dropVoucher6: Item.ID { 4000524 }
    // Maple point
    static var maplePoint: Item.ID { 4001126 }
    // Meso sack
    static var mesoSack: Item.ID { 4000309 }
    static var bigMesoSack: Item.ID { 4000310 }
    static var gigaMesoSack: Item.ID { 4000311 }
    static var teraMesoSack: Item.ID { 4000312 }
    // Guide book
    static var questGuidebook: Item.ID { 4160000 }
    static var scrollGuidebook: Item.ID { 4161000 }
    // Beginner skill
    static var beginnersMapleGlove: Item.ID { 2080000 }
    // Cash shop
    static var meritMedal: Item.ID { 1142342 }
    static var flameCircle: Item.ID { 1002831 }
    static var giantFlameCircle: Item.ID { 1002832 }
    // Quest item
    static var pinkCocoaFruit: Item.ID { 4031110 }
    static var cocoaFruit: Item.ID { 4031111 }
    static var stainlessSteel: Item.ID { 4000276 }
    static var icicle: Item.ID { 4000242 }
    static var mapleLeafHigh: Item.ID { 4003000 }
    // Upgrade scroll
    static var shieldScrollForDefense: Item.ID { 2040702 }
    static var shieldScrollForAttack: Item.ID { 2040715 }
    static var armorScrollForHP: Item.ID { 2040902 }
    static var armorScrollForMP: Item.ID { 2040903 }
    static var armorScrollForDefense: Item.ID { 2040904 }
    static var armorScrollForSpeed: Item.ID { 2040905 }
    static var accessoryForMagicDefense: Item.ID { 2040922 }
    static var accessoryForMagicAttack: Item.ID { 2040923 }
    static var accessoryForDefense: Item.ID { 2040930 }
    static var accessoryForSpeed: Item.ID { 2040931 }
    static var accessoryForJump: Item.ID { 2040932 }
    static var accessoryForAccuracy: Item.ID { 2040933 }
    static var accessoryForAvoid: Item.ID { 2040934 }
    static var accessoryForHP: Item.ID { 2040935 }
    static var accessoryForMP: Item.ID { 2040936 }
    static var accessoryForAllStat: Item.ID { 2040952 }
    static var accessoryForStr: Item.ID { 2040953 }
    static var accessoryForDex: Item.ID { 2040954 }
    static var accessoryForInt: Item.ID { 2040955 }
    static var accessoryForLuk: Item.ID { 2040956 }
    // Scroll protection
    static var scrollProtectionForAccessory: Item.ID { 2048000 }
    static var scrollProtectionForArmor: Item.ID { 2048100 }
    static var scrollProtectionForShield: Item.ID { 2048200 }
    static var scrollProtectionForWeapon: Item.ID { 2048300 }
    static var scrollProtectionForAccessory2: Item.ID { 2048301 }
    static var scrollProtectionForArmor2: Item.ID { 2048302 }
    static var scrollProtectionForShield2: Item.ID { 2048303 }
    static var scrollProtectionForWeapon2: Item.ID { 2048304 }
    static var scrollProtectionForAccessory3: Item.ID { 2048305 }
    static var scrollProtectionForArmor3: Item.ID { 2048306 }
    static var scrollProtectionForShield3: Item.ID { 2048307 }
    static var scrollProtectionForWeapon3: Item.ID { 2048308 }
    // Mastery book
    static var masteryBook20: Item.ID { 2290285 }
    static var masteryBook30: Item.ID { 2290286 }
    static var masteryBook70: Item.ID { 2290287 }
    static var masteryBook80: Item.ID { 2290288 }
    static var masteryBook100: Item.ID { 2290289 }
    // Megaphone
    static var megaphone: Item.ID { 5076000 }
    static var skullMegaphone: Item.ID { 5076001 }
    static var superMegaphone: Item.ID { 5076002 }
    // Cube
    static var premiumCube: Item.ID { 5062002 }
    static var superCube: Item.ID { 5062009 }
    static var meisterCube: Item.ID { 5062010 }
    static var redCube: Item.ID { 5062000 }
    static var blackCube: Item.ID { 5062001 }
    static var epicPotentialScroll: Item.ID { 2049400 }
    // Other
    static var buffFreezer: Item.ID { 2430713 }
    static var profanityFilter: Item.ID { 2450026 }
    static var pigmySap: Item.ID { 2050017 }
    static var spellTrace: Item.ID { 4001839 }
    static var chaosFragment: Item.ID { 4001832 }
    static var fusionAnvil: Item.ID { 2430709 }
    static var superMegaphone1: Item.ID { 5079001 }
    static var superMegaphone2: Item.ID { 5079002 }
    static var superMegaphone3: Item.ID { 5079003 }
    static var superMegaphone4: Item.ID { 5079004 }
    static var superMegaphone5: Item.ID { 5079005 }
    static var superMegaphone6: Item.ID { 5079006 }
    static var superMegaphone7: Item.ID { 5079007 }
    static var superMegaphone8: Item.ID { 5079008 }
    static var superMegaphone9: Item.ID { 5079009 }
    static var superMegaphone10: Item.ID { 5079010 }
}
