//
//  Map.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public extension Map {
    
    var isCygnusIntro: Bool {
        return rawValue >= Map.cygnusIntroLocationMin.rawValue
            && rawValue <= Map.cygnusIntroLocationMax.rawValue
    }
}

public extension Map {
    
    // Special
      static var none: Map { return 999999999 }
      static var gmMap: Map { return 180000000 }
      static var jail: Map { return 300000012 }
      static var developersHQ: Map { return 777777777 }

      // Misc
      static var orbisTowerBottom: Map { return 200082300 }
      static var internetCafe: Map { return 193000000 }
      static var crimsonwoodValley1: Map { return 610020000 }
      static var crimsonwoodValley2: Map { return 610020001 }
      static var henesysPQ: Map { return 910010000 }
      static var originOfClocktower: Map { return 220080001 }
      static var caveOfPianus: Map { return 230040420 }
      static var guildHQ: Map { return 200000301 }
      static var fmEntrance: Map { return 910000000 }

      // Beginner
      static var mushroomTown: Map { return 10000 }

      // Town
      static var southperry: Map { return 2000000 }
      static var amherst: Map { return 1000000 }
      static var henesys: Map { return 100000000 }
      static var ellinia: Map { return 101000000 }
      static var perion: Map { return 102000000 }
      static var kerningCity: Map { return 103000000 }
      static var lithHarbour: Map { return 104000000 }
      static var sleepywood: Map { return 105040300 }
      static var mushroomKingdom: Map { return 106020000 }
      static var florinaBeach: Map { return 110000000 }
      static var ereve: Map { return 130000000 }
      static var kerningSquare: Map { return 103040000 }
      static var rien: Map { return 140000000 }
      static var orbis: Map { return 200000000 }
      static var elNath: Map { return 211000000 }
      static var ludibrium: Map { return 220000000 }
      static var aquarium: Map { return 230000000 }
      static var leafre: Map { return 240000000 }
      static var neoCity: Map { return 240070000 }
      static var muLung: Map { return 250000000 }
      static var herbTown: Map { return 251000000 }
      static var omegaSector: Map { return 221000000 }
      static var koreanFolkTown: Map { return 222000000 }
      static var ariant: Map { return 260000000 }
      static var magatia: Map { return 261000000 }
      static var templeOfTime: Map { return 270000100 }
      static var ellinForest: Map { return 300000000 }
      static var singapore: Map { return 540000000 }
      static var boatQuayTown: Map { return 541000000 }
      static var kampungVillage: Map { return 551000000 }
      static var newLeafCity: Map { return 600000000 }
      static var mushroomShrine: Map { return 800000000 }
      static var showaTown: Map { return 801000000 }
      static var nautilusHarbor: Map { return 120000000 }
      static var happyville: Map { return 209000000 }
      static var showaSpaM: Map { return 809000101 }
      static var showaSpaF: Map { return 809000201 }

      // Travel
      static var fromLithToRien: Map { return 200090060 }
      static var fromRienToLith: Map { return 200090070 }
      static var dangerousForest: Map { return 140020300 }
      static var fromElliniaToEreve: Map { return 200090030 }
      static var skyFerry: Map { return 130000210 }
      static var fromEreveToEllinia: Map { return 200090031 }
      static var elliniaSkyFerry: Map { return 101000400 }
      static var fromEreveToOrbis: Map { return 200090021 }
      static var orbisStation: Map { return 200000161 }
      static var fromOrbisToEreve: Map { return 200090020 }

      // Aran
      static var aranTutorialStart: Map { return 914000000 }
      static var aranTutorialMax: Map { return 914000500 }
      static var aranIntro: Map { return 140090000 }
      static var aranTuto1: Map { return 914090010 }
      static var aranTuto2: Map { return 914090011 }
      static var aranTuto3: Map { return 914090012 }
      static var aranTuto4: Map { return 914090013 }
      static var aranPolearm: Map { return 914090100 }
      static var aranMaha: Map { return 914090200 }

      // Starting map
      static var startingMapNoblesse: Map { return 130030000 }

      // Cygnus intro
      static var cygnusIntroLocationMin: Map { return 913040000 }
      static var cygnusIntroLocationMax: Map { return 913040006 }
      static var cygnusIntroLead: Map { return 913040100 }
      static var cygnusIntroWarrior: Map { return 913040101 }
      static var cygnusIntroBowman: Map { return 913040102 }
      static var cygnusIntroMage: Map { return 913040103 }
      static var cygnusIntroPirate: Map { return 913040104 }
      static var cygnusIntroThief: Map { return 913040105 }
      static var cygnusIntroConclusion: Map { return 913040106 }

      // Event
      static var eventCoconutHarvest: Map { return 109080000 }
      static var eventOxQuiz: Map { return 109020001 }
      static var eventPhysicalFitness: Map { return 109040000 }
      static var eventOlaOla0: Map { return 109030001 }
      static var eventOlaOla1: Map { return 109030101 }
      static var eventOlaOla2: Map { return 109030201 }
      static var eventOlaOla3: Map { return 109030301 }
      static var eventOlaOla4: Map { return 109030401 }
      static var eventSnowball: Map { return 109060000 }
      static var eventFindTheJewel: Map { return 109010000 }
      static var fitnessEventLast: Map { return 109040004 }
      static var olaEventLast1: Map { return 109030003 }
      static var olaEventLast2: Map { return 109030103 }
      static var witchTowerEntrance: Map { return 980040000 }
      static var eventWinner: Map { return 109050000 }
      static var eventExit: Map { return 109050001 }
      static var eventSnowballEntrance: Map { return 109060001 }

      // Self lootable maps
      static var happyvilleTreeMin: Map { return 209000001 }
      static var happyvilleTreeMax: Map { return 209000015 }
      static var gpqFountainMin: Map { return 990000500 }
      static var gpqFountainMax: Map { return 990000502 }

      // Dojo
      static var dojoSoloBase: Map { return 925020000 }
      static var dojoPartyBase: Map { return 925030000 }
      static var dojoExit: Map { return 925020002 }
      static var dojoMin: Map { return 925020000 }
      static var dojoMax: Map { return 925033804 }
      static var dojoPartyMin: Map { return 925030100 }
      static var dojoPartyMax: Map { return 925033804 }

      // Mini dungeon
      static var antTunnel2: Map { return 105050100 }
      static var caveOfMushroomsBase: Map { return 105050101 }
      static var sleepyDungeon4: Map { return 105040304 }
      static var golemsCastleRuinsBase: Map { return 105040320 }
      static var sahel2: Map { return 260020600 }
      static var hillOfSandstormsBase: Map { return 260020630 }
      static var rainForestEastOfHenesys: Map { return 100020000 }
      static var henesysPigFarmBase: Map { return 100020100 }
      static var coldCradle: Map { return 105090311 }
      static var drakesBlueCaveBase: Map { return 105090320 }
      static var eosTower76thTo90thFloor: Map { return 221023400 }
      static var drummerBunnysLairBase: Map { return 221023401 }
      static var battlefieldOfFireAndWater: Map { return 240020500 }
      static var roundTableOfKentaursBase: Map { return 240020512 }
      static var restoringMemoryBase: Map { return 240040800 }
      static var destroyedDragonNest: Map { return 240040520 }
      static var newtSecuredZoneBase: Map { return 240040900 }
      static var redNosePirateDen2: Map { return 251010402 }
      static var pillageOfTreasureIslandBase: Map { return 251010410 }
      static var labAreaC1: Map { return 261020300 }
      static var criticalErrorBase: Map { return 261020301 }
      static var fantasyThemePark3: Map { return 551030000 }
      static var longestRideOnByebyeStation: Map { return 551030001 }

      // Boss rush
      static var bossRushMin: Map { return 970030100 }
      static var bossRushMax: Map { return 970042711 }

      // ARPQ
      static var arpqLobby: Map { return 980010000 }
      static var arpqArena1: Map { return 980010101 }
      static var arpqArena2: Map { return 980010201 }
      static var arpqArena3: Map { return 980010301 }
      static var arpqKingsRoom: Map { return 980010010 }

      // Nett's pyramid
      static var nettsPyramid: Map { return 926010001 }
      static var nettsPyramidSoloBase: Map { return 926010100 }
      static var nettsPyramidPartyBase: Map { return 926020100 }
      static var nettsPyramidMin: Map { return 926010100 }
      static var nettsPyramidMax: Map { return 926023500 }

      // Fishing
      static var onTheWayToTheHarbor: Map { return 120010000 }
      static var pierOnTheBeach: Map { return 251000100 }
      static var peacefulShip: Map { return 541010110 }

      // Wedding
      static var amoria: Map { return 680000000 }
      static var chapelWeddingAltar: Map { return 680000110 }
      static var cathedralWeddingAltar: Map { return 680000210 }
      static var weddingPhoto: Map { return 680000300 }
      static var weddingExit: Map { return 680000500 }

      // Statue
      static var hallOfWarriors: Map { return 102000004 }
      static var hallOfMagicians: Map { return 101000004 }
      static var hallOfBowmen: Map { return 100000204 }
      static var hallOfThieves: Map { return 103000008 }
      static var nautilusTrainingRoom: Map { return 120000105 }
      static var knightsChamber: Map { return 130000100 }
      static var knightsChamber2: Map { return 130000110 }
      static var knightsChamber3: Map { return 130000120 }
      static var knightsChamberLarge: Map { return 130000101 }
      static var palaceOfTheMaster: Map { return 140010110 }

      // gm-goto
      static var excavationSite: Map { return 990000000 }
      static var someoneElsesHouse: Map { return 100000005 }
      static var griffeyForest: Map { return 240020101 }
      static var manonsForest: Map { return 240020401 }
      static var hollowedGround: Map { return 682000001 }
      static var cursedSanctuary: Map { return 105090900 }
      static var doorToZakum: Map { return 211042300 }
      static var dragonNestLeftBehind: Map { return 240040511 }
      static var henesysPark: Map { return 951000000 }
      static var henesysRuins: Map { return 951000100 }
      static var entranceToCrimsonwoodKeep: Map { return 610010000 }
      static var hallOfMushmom: Map { return 682000003 }
}
