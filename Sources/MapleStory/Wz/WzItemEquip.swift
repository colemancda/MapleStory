//
//  WzItemEquip.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Equipment item entry parsed from Item.wz/Equip/<group>.img.xml
public struct WzItemEquip: Equatable, Sendable {

    public let id: UInt32

    // MARK: Info

    public let price: Int32
    public let slotMax: Int32
    public let isCash: Bool
    public let name: String?
    public let description: String?

    // MARK: Stats

    /// Equipment type/slot (hat, coat, pants, shoes, weapon, etc.)
    public let type: EquipType

    /// Job requirements (bitmask)
    public let job: UInt16
    public let requiredLevel: UInt8
    public let requiredStr: UInt16
    public let requiredDex: UInt16
    public let requiredInt: UInt16
    public let requiredLuk: UInt16

    /// Base stats
    public let str: UInt16
    public let dex: UInt16
    public let int: UInt16
    public let luk: UInt16
    public let hp: UInt16
    public let mp: UInt16
    public let weaponAttack: UInt16
    public let magicAttack: UInt16
    public let weaponDefense: UInt16
    public let magicDefense: UInt16
    public let accuracy: UInt16
    public let avoid: UInt16
    public let speed: UInt16
    public let jump: UInt16

    /// Upgrade information
    public let slots: Int8
    public let upgradeSlots: Int8
    public let scrollSuccesses: Int8

    public init(
        id: UInt32,
        price: Int32,
        slotMax: Int32,
        isCash: Bool,
        name: String?,
        description: String?,
        type: EquipType,
        job: UInt16,
        requiredLevel: UInt8,
        requiredStr: UInt16,
        requiredDex: UInt16,
        requiredInt: UInt16,
        requiredLuk: UInt16,
        str: UInt16,
        dex: UInt16,
        int: UInt16,
        luk: UInt16,
        hp: UInt16,
        mp: UInt16,
        weaponAttack: UInt16,
        magicAttack: UInt16,
        weaponDefense: UInt16,
        magicDefense: UInt16,
        accuracy: UInt16,
        avoid: UInt16,
        speed: UInt16,
        jump: UInt16,
        slots: Int8,
        upgradeSlots: Int8,
        scrollSuccesses: Int8
    ) {
        self.id = id
        self.price = price
        self.slotMax = slotMax
        self.isCash = isCash
        self.name = name
        self.description = description
        self.type = type
        self.job = job
        self.requiredLevel = requiredLevel
        self.requiredStr = requiredStr
        self.requiredDex = requiredDex
        self.requiredInt = requiredInt
        self.requiredLuk = requiredLuk
        self.str = str
        self.dex = dex
        self.int = int
        self.luk = luk
        self.hp = hp
        self.mp = mp
        self.weaponAttack = weaponAttack
        self.magicAttack = magicAttack
        self.weaponDefense = weaponDefense
        self.magicDefense = magicDefense
        self.accuracy = accuracy
        self.avoid = avoid
        self.speed = speed
        self.jump = jump
        self.slots = slots
        self.upgradeSlots = upgradeSlots
        self.scrollSuccesses = scrollSuccesses
    }
}

// MARK: - Equip Type

public extension WzItemEquip {

    /// Equipment slot type
    enum EquipType: String, Sendable {
        // Accessories
        case faceAccessory = "FaceAccessory"
        case eyeAccessory = "EyeAccessory"
        case earring = "Earring"
        case pendant = "Pendant"
        case ring = "Ring"
        case pocket = "Pocket"

        // Armor
        case hat = "Hat"
        case coat = "Coat"        // Top
        case pants = "Pants"      // Bottom
        case longcoat = "Longcoat"
        case shoes = "Shoes"
        case gloves = "Gloves"
        case cape = "Cape"
        case shield = "Shield"

        // Weapons
        case weapon = "Weapon"
        case twoHandedWeapon = "TwoHandedWeapon"

        // Special
        case medal = "Medal"
        case medalBand = "MedalBand"
        case taming = "Taming"
        case tamingMob = "TamingMob"
        case saddle = "Saddle"
        case powerSource = "PowerSource"
        case mechHeart = "MechHeart"
        case mechSaddle = "MechSaddle"
        case dragonMask = "DragonMask"
        case dragonWing = "DragonWing"
        case dragonTail = "DragonTail"
        case dragonTailFin = "DragonTailFin"
        case petEquip = "PetEquip"
        case petLabel = "PetLabel"

        /// Unknown type
        case unknown = "Unknown"
    }
}

// MARK: - Parsing

public extension WzItemEquip {

    /// Parse a single equipment item node
    init(id: UInt32, node: WzNode) throws {
        self.id = id

        let infoNode = node["info"]
        func infoInt(_ key: String, default def: Int32 = 0) -> Int32 {
            infoNode?[key]?.intValue ?? def
        }
        func infoUInt16(_ key: String, default def: UInt16 = 0) -> UInt16 {
            UInt16(max(0, infoInt(key, default: Int32(def))))
        }
        func infoUInt8(_ key: String, default def: UInt8 = 0) -> UInt8 {
            UInt8(max(0, min(255, infoInt(key, default: Int32(def)))))
        }
        func infoString(_ key: String) -> String? {
            infoNode?[key]?.stringValue
        }

        self.price = infoInt("price")
        self.slotMax = infoInt("slotMax", default: 1)
        self.isCash = infoInt("cash") != 0
        self.name = infoString("name")
        self.description = infoString("desc")

        // Determine equip type from item ID
        self.type = Self.equipType(for: id)

        // Requirements
        self.job = UInt16(max(0, infoInt("reqJob")))
        self.requiredLevel = infoUInt8("reqLevel", default: 0)
        self.requiredStr = infoUInt16("reqSTR")
        self.requiredDex = infoUInt16("reqDEX")
        self.requiredInt = infoUInt16("reqINT")
        self.requiredLuk = infoUInt16("reqLUK")

        // Stats
        self.str = infoUInt16("incSTR")
        self.dex = infoUInt16("incDEX")
        self.int = infoUInt16("incINT")
        self.luk = infoUInt16("incLUK")
        self.hp = infoUInt16("incMHP")
        self.mp = infoUInt16("incMMP")
        self.weaponAttack = infoUInt16("incPAD")
        self.magicAttack = infoUInt16("incMAD")
        self.weaponDefense = infoUInt16("incPDD")
        self.magicDefense = infoUInt16("incMDD")
        self.accuracy = infoUInt16("incACC")
        self.avoid = infoUInt16("incEVA")
        self.speed = infoUInt16("incSpeed")
        self.jump = infoUInt16("incJump")

        // Upgrade info
        self.slots = Int8(infoInt("tuc"))
        self.upgradeSlots = Int8(infoInt("reqSlot", default: 1))
        self.scrollSuccesses = Int8(infoInt("cuc", default: 0))
    }

    /// Parse all items from a group file
    static func items(from node: WzNode) throws -> [WzItemEquip] {
        try node.children.map { child in
            guard let id = UInt32(child.name) else {
                throw WzParseError.invalidValue(child.name, attribute: "name")
            }
            return try WzItemEquip(id: id, node: child)
        }
    }

    static func items(contentsOf url: URL) throws -> [WzItemEquip] {
        let node = try WzXMLParser().parse(contentsOf: url)
        return try items(from: node)
    }

    /// Determine equip type from item ID
    private static func equipType(for itemId: UInt32) -> EquipType {
        let prefix = itemId / 1000

        switch prefix {
        // Face accessories (10000-10999)
        case 10000...10099:
            return .faceAccessory

        // Eye accessories (11000-11999)
        case 10200...10299:
            return .eyeAccessory

        // Earrings (10300-10399)
        case 10300...10399:
            return .earring

        // Pendants (11200-11299)
        case 11200...11299:
            return .pendant

        // Rings (11100-11199, 111200-111299)
        case 11100...11199, 111200...111299:
            return .ring

        // Pocket item (11600-11699)
        case 11600...11699:
            return .pocket

        // Hats (100000-100999)
        case 100000...100999:
            return .hat

        // Coats/Tops (104000-104999, 1050000-1050999)
        case 104000...104999, 1050000...1050999:
            return .coat

        // Pants/Bottoms (106000-106999)
        case 106000...106999:
            return .pants

        // Longcoats (105000-105999)
        case 105000...105999:
            return .longcoat

        // Shoes (107000-107999)
        case 107000...107999:
            return .shoes

        // Gloves (108000-108999)
        case 108000...108999:
            return .gloves

        // Capes (110000-110999)
        case 110000...110999:
            return .cape

        // Shields (109000-109999)
        case 109000...109999:
            return .shield

        // Weapons (121000-121999 for 1H, 122000-122999 for 2H, etc.)
        case 121000...121999, 122000...122999,
             123000...123999, 124000...124999,
             130000...130999, 131000...131999,
             132000...132999, 133000...133999,
             134000...134999, 137000...137999,
             138000...138999, 140000...140999,
             141000...141999, 142000...142999,
             143000...143999, 144000...144999,
             145000...145999, 146000...146999,
             147000...147999, 148000...148999,
             149000...149999:
            return .weapon

        // Medals (1140000-1140099)
        case 1140000...1140099:
            return .medal

        default:
            return .unknown
        }
    }
}
