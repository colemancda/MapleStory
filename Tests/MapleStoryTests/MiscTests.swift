//
//  MiscTests.swift
//
//  Tests for identifier constant tables, ban dates and the inventory cache.
//

import Foundation
import XCTest
@testable import MapleStory

final class MiscTests: XCTestCase {

    func testItemIDConstants() {
        let all: [Item.ID] = [
            .whitePotion, .bluePotion, .orangePotion, .manaElixir, .pendantOfTheSpirit,
            .heartShapedChocolate, .happyBirthday, .fishingChair, .miniGameBase, .matchCards,
            .magicalMitten, .rpsCertificateBase, .goldenMapleLeaf, .perfectPitch, .magicRock,
            .goldenChickenEffect, .bummerEffect, .arpqShield, .roaringTigerMessenger, .sorcerersPotion,
            .russellonsPills, .redBeanPorridge, .softWhiteBun, .airBubble, .relaxer,
            .subiThrowingStars, .hwabiThrowingStars, .balancedFury, .crystalIlbiThrowingStars, .devilRainThrowingStar,
            .bullet, .blazeCapsule, .glazeCapsule, .beginnersGuide, .legendsGuide,
            .noblesseGuide, .redHwarangShirt, .blackMartialArtsPants, .mithrilBattleGrieves, .gladius,
            .mithrilPoleArm, .mithrilMaul, .firemansAxe, .darkEngrit, .greenHuntersArmor,
            .greenHuntressArmor, .greenHuntersPants, .greenHuntressPants, .greenHunterBoots, .ryden,
            .mountainCrossbow, .blueWizardRobe, .purpleFairyTop, .purpleFairySkirt, .redMagicshoes,
            .mithrilWand, .circleWindedStaff, .darkBrownStealer, .redSteal, .darkBrownStealerPants,
            .redStealPants, .bronzeChainBoots, .steelGuards, .reefClaw, .brownPaulieBoots,
            .primeHands, .coldMind, .brownPollard, .snailShell, .blueSnailShell,
            .redSnailShell, .coldProtectionScroll, .spikesScroll, .vegasSpell10, .vegasSpell60,
            .chaosScroll60, .liarTreeSap, .mapleSyrup, .whiteScroll, .cleanSlate1,
            .cleanSlate3, .cleanSlate5, .cleanSlate20, .ringStr100Scroll, .dragonStoneScroll,
            .beltStr100Scroll, .allCurePotion, .eyedrop, .tonic, .holyWater,
            .antiBanishScroll, .dojoPartyAllCure, .carnivalPartyAllCure, .whiteElixir, .pharaohsBlessing1,
            .pharaohsBlessing2, .pharaohsBlessing3, .pharaohsBlessing4, .dragonPet, .roboPet,
            .mesoMagnet, .itemPouch, .itemIgnore, .petSnail, .permaPinkBean,
            .permaKino, .permaWhiteTiger, .permaMiniYeti, .basicMonsterCrystal1, .basicMonsterCrystal2,
            .basicMonsterCrystal3, .intermediateMonsterCrystal1, .intermediateMonsterCrystal2, .intermediateMonsterCrystal3, .advancedMonsterCrystal1,
            .advancedMonsterCrystal2, .advancedMonsterCrystal3, .npcWeatherGrowlie, .safetyCharm, .easterBasket,
            .easterCharm, .engagementBoxMoonstone, .engagementBoxStar, .engagementBoxGolden, .engagementBoxSilver,
            .emptyEngagementBoxMoonstone, .engagementRingMoonstone, .emptyEngagementBoxStar, .engagementRingStar, .emptyEngagementBoxGolden,
            .engagementRingGolden, .emptyEngagementBoxSilver, .engagementRingSilver, .noblesseMedal, .warriorMedal,
            .mageMedal, .archerMedal, .thiefMedal, .pirateMedal, .adventurersMedal,
            .worldMap, .townMap, .cashShopMap, .dropVoucher1, .dropVoucher2,
            .dropVoucher3, .dropVoucher4, .dropVoucher5, .dropVoucher6, .maplePoint,
            .mesoSack, .bigMesoSack, .gigaMesoSack, .teraMesoSack, .questGuidebook,
            .scrollGuidebook, .beginnersMapleGlove, .meritMedal, .flameCircle, .giantFlameCircle,
            .pinkCocoaFruit, .cocoaFruit, .stainlessSteel, .icicle, .mapleLeafHigh,
            .shieldScrollForDefense, .shieldScrollForAttack, .armorScrollForHP, .armorScrollForMP, .armorScrollForDefense,
            .armorScrollForSpeed, .accessoryForMagicDefense, .accessoryForMagicAttack, .accessoryForDefense, .accessoryForSpeed,
            .accessoryForJump, .accessoryForAccuracy, .accessoryForAvoid, .accessoryForHP, .accessoryForMP,
            .accessoryForAllStat, .accessoryForStr, .accessoryForDex, .accessoryForInt, .accessoryForLuk,
            .scrollProtectionForAccessory, .scrollProtectionForArmor, .scrollProtectionForShield, .scrollProtectionForWeapon, .scrollProtectionForAccessory2,
            .scrollProtectionForArmor2, .scrollProtectionForShield2, .scrollProtectionForWeapon2, .scrollProtectionForAccessory3, .scrollProtectionForArmor3,
            .scrollProtectionForShield3, .scrollProtectionForWeapon3, .masteryBook20, .masteryBook30, .masteryBook70,
            .masteryBook80, .masteryBook100, .megaphone, .skullMegaphone, .superMegaphone,
            .premiumCube, .superCube, .meisterCube, .redCube, .blackCube,
            .epicPotentialScroll, .buffFreezer, .profanityFilter, .pigmySap, .spellTrace,
            .chaosFragment, .fusionAnvil, .superMegaphone1, .superMegaphone2, .superMegaphone3,
            .superMegaphone4, .superMegaphone5, .superMegaphone6, .superMegaphone7, .superMegaphone8,
            .superMegaphone9, .superMegaphone10
        ]
        XCTAssertEqual(all.count, 227)
        XCTAssertTrue(all.allSatisfy { $0.rawValue > 0 })
    }

    func testMapIDConstants() {
        let all: [Map.ID] = [
            .mushroomTown, .southperry, .amherst, .henesys, .ellinia,
            .perion, .kerningCity, .lithHarbour, .sleepywood, .mushroomKingdom,
            .florinaBeach, .ereve, .kerningSquare, .rien, .orbis,
            .elNath, .ludibrium, .aquarium, .leafre, .neoCity,
            .muLung, .herbTown, .omegaSector, .koreanFolkTown, .ariant,
            .magatia, .templeOfTime, .ellinForest, .singapore, .boatQuayTown,
            .kampungVillage, .newLeafCity, .mushroomShrine, .showaTown, .nautilusHarbor,
            .happyville, .showaSpaM, .showaSpaF, .none, .gmMap,
            .jail, .developersHQ, .orbisTowerBottom, .internetCafe, .crimsonwoodValley1,
            .crimsonwoodValley2, .henesysPQ, .originOfClocktower, .caveOfPianus, .guildHQ,
            .fmEntrance, .fromLithToRien, .fromRienToLith, .dangerousForest, .fromElliniaToEreve,
            .skyFerry, .fromEreveToEllinia, .elliniaSkyFerry, .fromEreveToOrbis, .orbisStation,
            .fromOrbisToEreve, .aranTutorialStart, .aranTutorialMax, .aranIntro, .aranTuto1,
            .aranTuto2, .aranTuto3, .aranTuto4, .aranPolearm, .aranMaha,
            .startingMapNoblesse, .cygnusIntroLocationMin, .cygnusIntroLocationMax, .cygnusIntroLead, .cygnusIntroWarrior,
            .cygnusIntroBowman, .cygnusIntroMage, .cygnusIntroPirate, .cygnusIntroThief, .cygnusIntroConclusion,
            .eventCoconutHarvest, .eventOxQuiz, .eventPhysicalFitness, .eventOlaOla0, .eventOlaOla1,
            .eventOlaOla2, .eventOlaOla3, .eventOlaOla4, .eventSnowball, .eventFindTheJewel,
            .fitnessEventLast, .olaEventLast1, .olaEventLast2, .witchTowerEntrance, .eventWinner,
            .eventExit, .eventSnowballEntrance, .happyvilleTreeMin, .happyvilleTreeMax, .gpqFountainMin,
            .gpqFountainMax, .dojoSoloBase, .dojoPartyBase, .dojoExit, .dojoMin,
            .dojoMax, .dojoPartyMin, .dojoPartyMax, .antTunnel2, .caveOfMushroomsBase,
            .sleepyDungeon4, .golemsCastleRuinsBase, .sahel2, .hillOfSandstormsBase, .rainForestEastOfHenesys,
            .henesysPigFarmBase, .coldCradle, .drakesBlueCaveBase, .eosTower76thTo90thFloor, .drummerBunnysLairBase,
            .battlefieldOfFireAndWater, .roundTableOfKentaursBase, .restoringMemoryBase, .destroyedDragonNest, .newtSecuredZoneBase,
            .redNosePirateDen2, .pillageOfTreasureIslandBase, .labAreaC1, .criticalErrorBase, .fantasyThemePark3,
            .longestRideOnByebyeStation, .bossRushMin, .bossRushMax, .arpqLobby, .arpqArena1,
            .arpqArena2, .arpqArena3, .arpqKingsRoom, .nettsPyramid, .nettsPyramidSoloBase,
            .nettsPyramidPartyBase, .nettsPyramidMin, .nettsPyramidMax, .onTheWayToTheHarbor, .pierOnTheBeach,
            .peacefulShip, .amoria, .chapelWeddingAltar, .cathedralWeddingAltar, .weddingPhoto,
            .weddingExit, .hallOfWarriors, .hallOfMagicians, .hallOfBowmen, .hallOfThieves,
            .nautilusTrainingRoom, .knightsChamber, .knightsChamber2, .knightsChamber3, .knightsChamberLarge,
            .palaceOfTheMaster, .excavationSite, .someoneElsesHouse, .griffeyForest, .manonsForest,
            .hollowedGround, .cursedSanctuary, .doorToZakum, .dragonNestLeftBehind, .henesysPark,
            .henesysRuins, .entranceToCrimsonwoodKeep, .hallOfMushmom
        ]
        XCTAssertEqual(all.count, 173)
        XCTAssertTrue(all.allSatisfy { $0.rawValue > 0 })
    }

    func testTemporaryBanDate() {
        let date: TemporaryBanDate = 100
        XCTAssertEqual(date.rawValue, 100)
        XCTAssertEqual(TemporaryBanDate(rawValue: 42).rawValue, 42)
        // timeIntervalSince1970 conversion works
        let interval = date.timeIntervalSince1970
        let expected = Double(((Int64(100) * 10000) + 116444736000000000) / 1000)
        XCTAssertEqual(interval, expected)
    }

    func testCharacterInventoryCache() async {
        let character = Character(id: UUID(), index: 1, user: UUID(), world: UUID(), name: "InvTest", face: 1)

        // starts empty
        let empty = await character.getInventory()
        XCTAssertTrue(empty.equip.isEmpty)

        // set and read back
        var inventory = Inventory()
        inventory.use[1] = InventoryItem(itemId: 2000002, slot: 1, quantity: 3)
        await character.setInventory(inventory)

        let stored = await character.getInventory()
        XCTAssertEqual(stored.use[1]?.quantity, 3)

        // clear
        await CharacterInventoryCache.shared.clearInventory(for: character.id)
        let afterClear = await character.getInventory()
        XCTAssertTrue(afterClear.use.isEmpty)
    }
}
