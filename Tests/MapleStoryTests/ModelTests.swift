//
//  ModelTests.swift
//
//  Tests for MapleStory model value types.
//

import Foundation
import XCTest
@testable import MapleStory

final class ModelTests: XCTestCase {

    // MARK: - Identifiers

    func testItemID() {
        let id: Item.ID = 2000002
        XCTAssertEqual(id.rawValue, 2000002)
        XCTAssertEqual(id.description, "2000002")
        XCTAssertEqual(id.debugDescription, "2000002")
        XCTAssertEqual(Item.ID.whitePotion, 2000002)
        XCTAssertEqual(Item.ID.bluePotion, 2000003)
        XCTAssertEqual(Item.ID.beginnersGuide, 4161001)
        XCTAssertEqual(Item.ID.superMegaphone10, 5079010)
        XCTAssertEqual(Item.ID(rawValue: 5).rawValue, 5)
    }

    func testItem() throws {
        let item = Item(id: .whitePotion, name: "White Potion", descriptionText: "Recovers HP")
        XCTAssertEqual(item.id, .whitePotion)
        XCTAssertEqual(item.name, "White Potion")
        XCTAssertJSONRoundTrip(item)
    }

    func testMapID() {
        let id: Map.ID = 10000
        XCTAssertEqual(id.rawValue, 10000)
        XCTAssertEqual(id.description, "10000")
        XCTAssertEqual(id.debugDescription, "10000")
        XCTAssertEqual(Map.ID.mushroomTown, 10000)
        XCTAssertEqual(Map.ID.henesys, 100000000)
        XCTAssertEqual(Map.ID.none, 999999999)
        XCTAssertEqual(Map.ID.aranTutorialStart, 914000000)
        XCTAssertEqual(Map.ID.startingMapNoblesse, 130030000)
        XCTAssertEqual(Map.ID.hallOfMushmom, 682000003)
    }

    func testMap() throws {
        let map = Map(id: .henesys, name: "Henesys", streetName: "Victoria Road")
        XCTAssertEqual(map.id, .henesys)
        XCTAssertJSONRoundTrip(map)
    }

    func testKeyBinding() throws {
        let binding = KeyBinding(type: 4, action: 10)
        XCTAssertEqual(binding.type, 4)
        XCTAssertEqual(binding.action, 10)
        XCTAssertJSONRoundTrip(binding)
    }

    // MARK: - Credentials

    func testUsernameSanitized() {
        let username = Username(rawValue: "ColemanCDA")!
        XCTAssertEqual(username.sanitized().rawValue, "colemancda")
        XCTAssertEqual(username.description, "ColemanCDA")
        XCTAssertEqual(username.debugDescription, "ColemanCDA")
        XCTAssertJSONRoundTrip(username)
    }

    func testEmail() {
        let email = Email(rawValue: "alseycmiller@gmail.com")!
        XCTAssertEqual(email.rawValue, "alseycmiller@gmail.com")
        XCTAssertEqual(email.description, "alseycmiller@gmail.com")
        XCTAssertFalse(email.debugDescription.isEmpty)
        XCTAssertNil(Email(rawValue: "invalid"))
    }

    func testPassword() throws {
        let password = Password(rawValue: "test1234")!
        XCTAssertEqual(password.rawValue, "test1234")
        XCTAssertEqual(password.description, "test1234")
        XCTAssertEqual(password.debugDescription, "test1234")
        XCTAssertNil(Password(rawValue: ""))
    }

    // MARK: - Character Equipment

    func testCharacterEquipment() {
        var equipment: Character.Equipment = [
            5: 1040021,
            6: 1060016
        ]
        XCTAssertEqual(equipment.count, 2)
        XCTAssertFalse(equipment.isEmpty)
        XCTAssertEqual(equipment[5], 1040021)

        equipment[7] = 1072039
        XCTAssertEqual(equipment.count, 3)
        equipment[7] = nil
        XCTAssertEqual(equipment.count, 2)

        // Collection conformance
        XCTAssertEqual(equipment.startIndex, 0)
        XCTAssertEqual(equipment.endIndex, 2)
        let first = equipment[equipment.startIndex]
        XCTAssertNotNil(first)
        let mapped = equipment.map { $0.key }
        XCTAssertEqual(mapped.count, 2)

        // Dictionary conversion
        let dictionary = Dictionary(equipment)
        XCTAssertEqual(dictionary.count, 2)

        XCTAssertFalse(equipment.description.isEmpty)
        XCTAssertFalse(equipment.debugDescription.isEmpty)
    }

    func testEmptyEquipment() {
        let equipment = Character.Equipment()
        XCTAssertTrue(equipment.isEmpty)
        XCTAssertEqual(equipment.count, 0)
    }

    func testEquipmentJSONRoundTrip() throws {
        let equipment: Character.Equipment = [1: 100, 2: 200]
        XCTAssertJSONRoundTrip(equipment)
    }

    func testEquipmentSliceAndIterator() {
        let equipment: Character.Equipment = [1: 100, 2: 200, 3: 300]
        let slice = equipment[0..<2]
        XCTAssertEqual(slice.count, 2)

        var iterator = equipment.makeIterator()
        var seen = 0
        while iterator.next() != nil { seen += 1 }
        XCTAssertEqual(seen, 3)

        let element = Character.Equipment.Element(key: 5, value: 999)
        XCTAssertEqual(element.key, 5)
        XCTAssertEqual(element.value, 999)
    }

    func testEquipmentAttributeCodable() {
        let equipment: Character.Equipment = [1: 100, 2: 200]
        let attributeValue = equipment.attributeValue
        let restored = Character.Equipment(attributeValue: attributeValue)
        XCTAssertEqual(restored, equipment)
    }

    func testEquipmentUniqueKeysWithValues() {
        let equipment = Character.Equipment(uniqueKeysWithValues: [(1, 100), (2, 200)])
        XCTAssertEqual(equipment.count, 2)
        XCTAssertEqual(equipment[1], 100)
    }

    // MARK: - Character

    func testCharacterInit() throws {
        let character = Character(
            id: UUID(),
            index: 1,
            user: UUID(),
            world: UUID(),
            name: "Hero",
            face: 20000,
            equipment: [5: 1040021],
            maskedEquipment: [:]
        )
        XCTAssertEqual(character.name.rawValue, "Hero")
        XCTAssertEqual(character.level, 1)
        XCTAssertEqual(character.job, .beginner)
        XCTAssertEqual(character.currentMap, .mushroomTown)
        XCTAssertJSONRoundTrip(character)

        // Entity conformance
        XCTAssertFalse(Character.attributes.isEmpty)
        XCTAssertFalse(Character.relationships.isEmpty)
    }

    func testCharacterWithSession() throws {
        let character = Character(
            id: UUID(),
            index: 3,
            user: UUID(),
            world: UUID(),
            session: UUID(),
            name: "Sessioned",
            face: 20001,
            level: 50,
            job: .warrior,
            fame: 10,
            meso: 12345,
            isMarried: true
        )
        XCTAssertNotNil(character.session)
        XCTAssertEqual(character.level, 50)
        XCTAssertEqual(character.job, .warrior)
        XCTAssertJSONRoundTrip(character)
    }

    func testCharacterCreationValues() {
        let values = Character.CreationValues(
            name: "NewHero",
            face: 20000,
            hair: .buzz(.black),
            top: 1040021,
            bottom: 1060016,
            shoes: 1072039,
            weapon: 1302008
        )
        XCTAssertEqual(values.name.rawValue, "NewHero")
        XCTAssertEqual(values.job, .beginner)
        XCTAssertEqual(values.skinColor, .pale)

        let character = Character(create: values, index: 2, user: UUID(), world: UUID())
        XCTAssertEqual(character.name.rawValue, "NewHero")
        XCTAssertEqual(character.currentMap, .mushroomTown)
        XCTAssertEqual(character.spawnPoint, 0)
    }

    func testCharacterCreationValuesJobMaps() {
        func map(for job: Job) -> Map.ID {
            let values = Character.CreationValues(
                name: "Test", face: 1, hair: 30000,
                top: 0, bottom: 0, shoes: 0, weapon: 0, job: job
            )
            return Character(create: values, index: 1, user: UUID(), world: UUID()).currentMap
        }
        XCTAssertEqual(map(for: .beginner), .mushroomTown)
        XCTAssertEqual(map(for: .legend), .aranTutorialStart)
        XCTAssertEqual(map(for: .noblesse), .startingMapNoblesse)
        XCTAssertEqual(map(for: .warrior), .mushroomTown)
    }

    // MARK: - Pet

    func testPet() throws {
        let pet = Pet(id: 1, itemID: 5000054, name: "Fluffy", ownerID: UUID())
        XCTAssertEqual(pet.name, "Fluffy")
        XCTAssertEqual(pet.level, 1)
        XCTAssertEqual(pet.fullness, 100)
        XCTAssertFalse(pet.isSpawned)
        XCTAssertJSONRoundTrip(pet)

        let position = PetPosition(x: 10, y: -20)
        XCTAssertEqual(position.x, 10)
        XCTAssertEqual(position.y, -20)
        XCTAssertJSONRoundTrip(position)
    }

    // MARK: - Inventory

    func testInventory() throws {
        var inventory = Inventory()
        XCTAssertTrue(inventory.equip.isEmpty)

        let item = InventoryItem(itemId: 2000002, slot: 1, quantity: 5)
        XCTAssertFalse(item.isEquipment)
        XCTAssertTrue(item.isStackable)

        inventory[.use] = [1: item]
        XCTAssertEqual(inventory.use.count, 1)
        XCTAssertEqual(inventory[.use][1]?.quantity, 5)

        XCTAssertEqual(inventory.countItem(2000002, in: .use), 5)
        XCTAssertEqual(inventory.countItem(9999, in: .use), 0)
        XCTAssertEqual(inventory.findEmptySlot(in: .use), 2)
        XCTAssertEqual(inventory.findEmptySlot(in: .equip), 1)

        XCTAssertJSONRoundTrip(inventory)
    }

    func testEquipData() throws {
        let equip = EquipData(slot: -11, str: 5, weaponAttack: 30)
        XCTAssertEqual(equip.slot, -11)
        XCTAssertEqual(equip.str, 5)
        XCTAssertEqual(equip.slots, 7)

        let item = InventoryItem(itemId: 1302008, slot: -11, equip: equip)
        XCTAssertTrue(item.isEquipment)
        XCTAssertFalse(item.isStackable)
        XCTAssertJSONRoundTrip(item)
    }

    func testInventoryType() {
        XCTAssertEqual(InventoryType.equip.rawValue, 1)
        XCTAssertEqual(InventoryType.cash.rawValue, 5)
    }

    func testEquipSlotConstants() {
        XCTAssertEqual(Int8.equipHat, -1)
        XCTAssertEqual(Int8.equipWeapon, -11)
        XCTAssertEqual(Int8.equipPetEquip, -17)
        XCTAssertEqual(Int8.inventoryStart, 1)
        XCTAssertEqual(Int8.inventoryEnd, 100)
    }

    // MARK: - Guild

    func testGuild() throws {
        let leader = UUID()
        let member = GuildMember(characterID: leader, characterName: "Leader", rank: .master, online: true)
        var guild = Guild(id: 1000, name: "Legends", leaderID: leader, members: [leader: member])
        XCTAssertEqual(guild.memberCount, 1)
        XCTAssertEqual(guild.capacity, 30)
        XCTAssertFalse(guild.isFull)

        guild.capacity = 1
        XCTAssertTrue(guild.isFull)

        XCTAssertEqual(GuildRank.master.rawValue, 1)
        XCTAssertEqual(GuildRank.unavailable.rawValue, 5)
        XCTAssertJSONRoundTrip(guild)
        XCTAssertJSONRoundTrip(member)
    }

    // MARK: - Party

    func testParty() throws {
        let leader = UUID()
        let member = PartyMember(
            characterID: leader,
            characterName: "Leader",
            job: .warrior,
            level: 30,
            channel: 1,
            map: .henesys
        )
        var party = Party(id: 2000, leaderID: leader, members: [leader: member])
        XCTAssertEqual(party.memberCount, 1)
        XCTAssertFalse(party.isFull)

        // fill to 6
        for _ in 0..<6 {
            let id = UUID()
            party.members[id] = PartyMember(
                characterID: id, characterName: "M", job: .beginner,
                level: 1, channel: 1, map: .mushroomTown
            )
        }
        XCTAssertTrue(party.isFull)

        XCTAssertEqual(PartyMemberStatus.online.rawValue, 0)
        XCTAssertEqual(PartyMemberStatus.offline.rawValue, 1)
        XCTAssertJSONRoundTrip(member)
    }

    // MARK: - Quest

    func testQuestState() throws {
        var state = QuestState(questID: 1000, status: .started)
        XCTAssertEqual(state.status, .started)
        XCTAssertEqual(state.completionCount, 0)
        state.progress["mob"] = 5
        XCTAssertEqual(state.progress["mob"], 5)
        XCTAssertJSONRoundTrip(state)

        XCTAssertEqual(QuestStatus.notStarted.rawValue, 0)
        XCTAssertEqual(QuestStatus.completed.rawValue, 2)
    }

    func testQuestReward() throws {
        let reward = QuestReward(exp: 100, meso: 50, items: [4000313: 1], job: nil)
        XCTAssertEqual(reward.exp, 100)
        XCTAssertEqual(reward.items[4000313], 1)
        XCTAssertJSONRoundTrip(reward)
    }

    func testQuestRequirement() throws {
        let requirement = QuestRequirement(
            minLevel: 10,
            maxLevel: 30,
            completedQuests: [999: 1],
            startNPCs: [1001],
            endNPCs: [1002],
            repeatable: false
        )
        XCTAssertTrue(requirement.canStartAt(npcID: 1001))
        XCTAssertFalse(requirement.canStartAt(npcID: 2000))
        XCTAssertTrue(requirement.canCompleteAt(npcID: 1002))
        XCTAssertFalse(requirement.canCompleteAt(npcID: 3000))
        XCTAssertFalse(requirement.canRepeat(completionCount: 1))
        XCTAssertTrue(requirement.canRepeat(completionCount: 0))

        let character = Character(id: UUID(), index: 1, user: UUID(), world: UUID(), name: "Q", face: 1, level: 20)

        // meets level but missing completed quest
        XCTAssertFalse(requirement.canStart(character: character, questStates: [:]))
        // has completed quest
        let states: [QuestID: QuestState] = [999: {
            var s = QuestState(questID: 999); s.completionCount = 1; return s
        }()]
        XCTAssertTrue(requirement.canStart(character: character, questStates: states))

        // level too low
        let lowLevel = Character(id: UUID(), index: 1, user: UUID(), world: UUID(), name: "Q", face: 1, level: 5)
        XCTAssertFalse(requirement.canStart(character: lowLevel, questStates: states))

        // empty NPC lists allow any
        let anyReq = QuestRequirement()
        XCTAssertTrue(anyReq.canStartAt(npcID: 42))
        XCTAssertTrue(anyReq.canCompleteAt(npcID: 42))
        XCTAssertJSONRoundTrip(requirement)
    }
}
