//
//  Map.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public extension Map.ID {
    
    var isCygnusIntro: Bool {
        return rawValue >= Map.ID.cygnusIntroLocationMin.rawValue
            && rawValue <= Map.ID.cygnusIntroLocationMax.rawValue
    }
}

public extension Map.ID {
    
    // Special
      static var none: Map.ID { return 999999999 }
      static var gmMap: Map.ID { return 180000000 }
      static var jail: Map.ID { return 300000012 }
      static var developersHQ: Map.ID { return 777777777 }

      // Misc
      static var orbisTowerBottom: Map.ID { return 200082300 }
      static var internetCafe: Map.ID { return 193000000 }
      static var crimsonwoodValley1: Map.ID { return 610020000 }
      static var crimsonwoodValley2: Map.ID { return 610020001 }
      static var henesysPQ: Map.ID { return 910010000 }
      static var originOfClocktower: Map.ID { return 220080001 }
      static var caveOfPianus: Map.ID { return 230040420 }
      static var guildHQ: Map.ID { return 200000301 }
      static var fmEntrance: Map.ID { return 910000000 }

      // Beginner
      static var mushroomTown: Map.ID { return 10000 }

      // Town
      static var southperry: Map.ID { return 2000000 }
      static var amherst: Map.ID { return 1000000 }
      static var henesys: Map.ID { return 100000000 }
      static var ellinia: Map.ID { return 101000000 }
      static var perion: Map.ID { return 102000000 }
      static var kerningCity: Map.ID { return 103000000 }
      static var lithHarbour: Map.ID { return 104000000 }
      static var sleepywood: Map.ID { return 105040300 }
      static var mushroomKingdom: Map.ID { return 106020000 }
      static var florinaBeach: Map.ID { return 110000000 }
      static var ereve: Map.ID { return 130000000 }
      static var kerningSquare: Map.ID { return 103040000 }
      static var rien: Map.ID { return 140000000 }
      static var orbis: Map.ID { return 200000000 }
      static var elNath: Map.ID { return 211000000 }
      static var ludibrium: Map.ID { return 220000000 }
      static var aquarium: Map.ID { return 230000000 }
      static var leafre: Map.ID { return 240000000 }
      static var neoCity: Map.ID { return 240070000 }
      static var muLung: Map.ID { return 250000000 }
      static var herbTown: Map.ID { return 251000000 }
      static var omegaSector: Map.ID { return 221000000 }
      static var koreanFolkTown: Map.ID { return 222000000 }
      static var ariant: Map.ID { return 260000000 }
      static var magatia: Map.ID { return 261000000 }
      static var templeOfTime: Map.ID { return 270000100 }
      static var ellinForest: Map.ID { return 300000000 }
      static var singapore: Map.ID { return 540000000 }
      static var boatQuayTown: Map.ID { return 541000000 }
      static var kampungVillage: Map.ID { return 551000000 }
      static var newLeafCity: Map.ID { return 600000000 }
      static var mushroomShrine: Map.ID { return 800000000 }
      static var showaTown: Map.ID { return 801000000 }
      static var nautilusHarbor: Map.ID { return 120000000 }
      static var happyville: Map.ID { return 209000000 }
      static var showaSpaM: Map.ID { return 809000101 }
      static var showaSpaF: Map.ID { return 809000201 }

      // Travel
      static var fromLithToRien: Map.ID { return 200090060 }
      static var fromRienToLith: Map.ID { return 200090070 }
      static var dangerousForest: Map.ID { return 140020300 }
      static var fromElliniaToEreve: Map.ID { return 200090030 }
      static var skyFerry: Map.ID { return 130000210 }
      static var fromEreveToEllinia: Map.ID { return 200090031 }
      static var elliniaSkyFerry: Map.ID { return 101000400 }
      static var fromEreveToOrbis: Map.ID { return 200090021 }
      static var orbisStation: Map.ID { return 200000161 }
      static var fromOrbisToEreve: Map.ID { return 200090020 }

      // Aran
      static var aranTutorialStart: Map.ID { return 914000000 }
      static var aranTutorialMax: Map.ID { return 914000500 }
      static var aranIntro: Map.ID { return 140090000 }
      static var aranTuto1: Map.ID { return 914090010 }
      static var aranTuto2: Map.ID { return 914090011 }
      static var aranTuto3: Map.ID { return 914090012 }
      static var aranTuto4: Map.ID { return 914090013 }
      static var aranPolearm: Map.ID { return 914090100 }
      static var aranMaha: Map.ID { return 914090200 }

      // Starting map
      static var startingMapNoblesse: Map.ID { return 130030000 }

      // Cygnus intro
      static var cygnusIntroLocationMin: Map.ID { return 913040000 }
      static var cygnusIntroLocationMax: Map.ID { return 913040006 }
      static var cygnusIntroLead: Map.ID { return 913040100 }
      static var cygnusIntroWarrior: Map.ID { return 913040101 }
      static var cygnusIntroBowman: Map.ID { return 913040102 }
      static var cygnusIntroMage: Map.ID { return 913040103 }
      static var cygnusIntroPirate: Map.ID { return 913040104 }
      static var cygnusIntroThief: Map.ID { return 913040105 }
      static var cygnusIntroConclusion: Map.ID { return 913040106 }

      // Event
      static var eventCoconutHarvest: Map.ID { return 109080000 }
      static var eventOxQuiz: Map.ID { return 109020001 }
      static var eventPhysicalFitness: Map.ID { return 109040000 }
      static var eventOlaOla0: Map.ID { return 109030001 }
      static var eventOlaOla1: Map.ID { return 109030101 }
      static var eventOlaOla2: Map.ID { return 109030201 }
      static var eventOlaOla3: Map.ID { return 109030301 }
      static var eventOlaOla4: Map.ID { return 109030401 }
      static var eventSnowball: Map.ID { return 109060000 }
      static var eventFindTheJewel: Map.ID { return 109010000 }
      static var fitnessEventLast: Map.ID { return 109040004 }
      static var olaEventLast1: Map.ID { return 109030003 }
      static var olaEventLast2: Map.ID { return 109030103 }
      static var witchTowerEntrance: Map.ID { return 980040000 }
      static var eventWinner: Map.ID { return 109050000 }
      static var eventExit: Map.ID { return 109050001 }
      static var eventSnowballEntrance: Map.ID { return 109060001 }

      // Self lootable maps
      static var happyvilleTreeMin: Map.ID { return 209000001 }
      static var happyvilleTreeMax: Map.ID { return 209000015 }
      static var gpqFountainMin: Map.ID { return 990000500 }
      static var gpqFountainMax: Map.ID { return 990000502 }

      // Dojo
      static var dojoSoloBase: Map.ID { return 925020000 }
      static var dojoPartyBase: Map.ID { return 925030000 }
      static var dojoExit: Map.ID { return 925020002 }
      static var dojoMin: Map.ID { return 925020000 }
      static var dojoMax: Map.ID { return 925033804 }
      static var dojoPartyMin: Map.ID { return 925030100 }
      static var dojoPartyMax: Map.ID { return 925033804 }

      // Mini dungeon
      static var antTunnel2: Map.ID { return 105050100 }
      static var caveOfMushroomsBase: Map.ID { return 105050101 }
      static var sleepyDungeon4: Map.ID { return 105040304 }
      static var golemsCastleRuinsBase: Map.ID { return 105040320 }
      static var sahel2: Map.ID { return 260020600 }
      static var hillOfSandstormsBase: Map.ID { return 260020630 }
      static var rainForestEastOfHenesys: Map.ID { return 100020000 }
      static var henesysPigFarmBase: Map.ID { return 100020100 }
      static var coldCradle: Map.ID { return 105090311 }
      static var drakesBlueCaveBase: Map.ID { return 105090320 }
      static var eosTower76thTo90thFloor: Map.ID { return 221023400 }
      static var drummerBunnysLairBase: Map.ID { return 221023401 }
      static var battlefieldOfFireAndWater: Map.ID { return 240020500 }
      static var roundTableOfKentaursBase: Map.ID { return 240020512 }
      static var restoringMemoryBase: Map.ID { return 240040800 }
      static var destroyedDragonNest: Map.ID { return 240040520 }
      static var newtSecuredZoneBase: Map.ID { return 240040900 }
      static var redNosePirateDen2: Map.ID { return 251010402 }
      static var pillageOfTreasureIslandBase: Map.ID { return 251010410 }
      static var labAreaC1: Map.ID { return 261020300 }
      static var criticalErrorBase: Map.ID { return 261020301 }
      static var fantasyThemePark3: Map.ID { return 551030000 }
      static var longestRideOnByebyeStation: Map.ID { return 551030001 }

      // Boss rush
      static var bossRushMin: Map.ID { return 970030100 }
      static var bossRushMax: Map.ID { return 970042711 }

      // ARPQ
      static var arpqLobby: Map.ID { return 980010000 }
      static var arpqArena1: Map.ID { return 980010101 }
      static var arpqArena2: Map.ID { return 980010201 }
      static var arpqArena3: Map.ID { return 980010301 }
      static var arpqKingsRoom: Map.ID { return 980010010 }

      // Nett's pyramid
      static var nettsPyramid: Map.ID { return 926010001 }
      static var nettsPyramidSoloBase: Map.ID { return 926010100 }
      static var nettsPyramidPartyBase: Map.ID { return 926020100 }
      static var nettsPyramidMin: Map.ID { return 926010100 }
      static var nettsPyramidMax: Map.ID { return 926023500 }

      // Fishing
      static var onTheWayToTheHarbor: Map.ID { return 120010000 }
      static var pierOnTheBeach: Map.ID { return 251000100 }
      static var peacefulShip: Map.ID { return 541010110 }

      // Wedding
      static var amoria: Map.ID { return 680000000 }
      static var chapelWeddingAltar: Map.ID { return 680000110 }
      static var cathedralWeddingAltar: Map.ID { return 680000210 }
      static var weddingPhoto: Map.ID { return 680000300 }
      static var weddingExit: Map.ID { return 680000500 }

      // Statue
      static var hallOfWarriors: Map.ID { return 102000004 }
      static var hallOfMagicians: Map.ID { return 101000004 }
      static var hallOfBowmen: Map.ID { return 100000204 }
      static var hallOfThieves: Map.ID { return 103000008 }
      static var nautilusTrainingRoom: Map.ID { return 120000105 }
      static var knightsChamber: Map.ID { return 130000100 }
      static var knightsChamber2: Map.ID { return 130000110 }
      static var knightsChamber3: Map.ID { return 130000120 }
      static var knightsChamberLarge: Map.ID { return 130000101 }
      static var palaceOfTheMaster: Map.ID { return 140010110 }

      // gm-goto
      static var excavationSite: Map.ID { return 990000000 }
      static var someoneElsesHouse: Map.ID { return 100000005 }
      static var griffeyForest: Map.ID { return 240020101 }
      static var manonsForest: Map.ID { return 240020401 }
      static var hollowedGround: Map.ID { return 682000001 }
      static var cursedSanctuary: Map.ID { return 105090900 }
      static var doorToZakum: Map.ID { return 211042300 }
      static var dragonNestLeftBehind: Map.ID { return 240040511 }
      static var henesysPark: Map.ID { return 951000000 }
      static var henesysRuins: Map.ID { return 951000100 }
      static var entranceToCrimsonwoodKeep: Map.ID { return 610010000 }
      static var hallOfMushmom: Map.ID { return 682000003 }
}
