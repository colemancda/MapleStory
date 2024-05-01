//
//  ServerOpcode.swift
//  
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation

/// Enum representing packet headers for network communication.
public enum ServerOpcode: UInt16, Codable, CaseIterable {
    
    /// PING packet header.
    ///
    /// Used for ping-pong communication to check server/client connection.
    case ping = 0x11
    
    /// Login status packet header.
    case loginStatus = 0x00
    
    /// Send link packet header.
    case sendLink = 0x01
    
    /// Server status packet header.
    case serverstatus = 0x03
    
    /// Gender done packet header.
    case genderDone = 0x04
    
    /// PIN operation packet header.
    case pinOperation = 0x06
    
    /// PIN assigned packet header.
    case pinAssigned = 0x07
    
    /// All character list packet header.
    case allCharlist = 0x08
    
    /// Server list packet header.
    case serverList = 0x0A
    
    /// Character list packet header.
    case characterList = 0x0B
    
    /// Server IP packet header.
    case serverIP = 0x0C
    
    /// Character name response packet header.
    case characterNameResponse = 0x0D
    
    /// Add new character entry packet header.
    case createCharacterResponse = 0x0E
    
    /// Delete character response packet header.
    case deleteCharacter = 0x0F
    
    /// Channel selected packet header.
    case channelSelected = 0x14
    
    /// Re-log response packet header.
    case relogResponse = 0x16
    
    /// Change channel packet header.
    case changeChannel = 0x10
    
    /// Modify inventory item packet header.
    case modifyInventoryItem = 0x1A
    
    /// Update stats packet header.
    case updateStats = 0x1C
    
    /// Give buff packet header.
    case giveBuff = 0x1D
    
    /// Cancel buff packet header.
    case cancelBuff = 0x1E
    
    /// Update skills packet header.
    case updateSkills = 0x21
    
    /// Fame response packet header.
    case fameResponse = 0x23
    
    /// Show status info packet header.
    case showStatusInfo = 0x24
    
    /// Show notes packet header.
    case showNotes = 0x26
    
    /// Show quest completion packet header.
    case showQuestCompletion = 0x2E
    
    /// Use skill book packet header.
    case useSkillBook = 0x30
    
    /// Report player message packet header.
    case reportPlayerMsg = 0x34
    
    /// BBS operation packet header.
    case bbsOperation = 0x38
    
    /// Character info packet header.
    case charInfo = 0x3A
    
    /// Party operation packet header.
    case partyOperation = 0x3B
    
    /// Buddylist packet header.
    case buddylist = 0x3C
    
    /// Guild operation packet header.
    case guildOperation = 0x3E
    
    /// Alliance operation packet header.
    case allianceOperation = 0x3F
    
    /// Spawn portal packet header.
    case spawnPortal = 0x40
    
    /// Server message packet header.
    case servermessage = 0x41
    
    /// Player NPC packet header.
    case playerNpc = 0x4E
    
    /// Avatar mega packet header.
    case avatarMega = 0x54
    
    /// Skill macro packet header.
    case skillMacro = 0x5B
    
    /// Warp to map packet header.
    case warpToMap = 0x5C
    
    /// CS open packet header.
    case csOpen = 0x5E
    
    /// Block portal packet header.
    case blockPortal = 0x62
    
    /// Show equip effect packet header.
    case showEquipEffect = 0x63
    
    /// Multichat packet header.
    case multichat = 0x64
    
    /// Whisper packet header.
    case whisper = 0x65
    
    /// Boss environment packet header.
    case bossEnv = 0x68
    
    /// Map effect packet header.
    case mapEffect = 0x69
    
    /// GM event instructions packet header.
    case gmeventInstructions = 0x6D
    
    /// Clock packet header.
    case clock = 0x6E
    
    /// Ariant scoreboard packet header.
    case ariantScoreboard = 0x76
    
    /// Spawn player packet header.
    case spawnPlayer = 0x78
    
    /// Remove player from map packet header.
    case removePlayerFromMap = 0x79
    
    /// Chat text packet header.
    case chattext = 0x7A
    
    /// Chalkboard packet header.
    case chalkboard = 0x7B
    
    /// Show scroll effect packet header.
    case showScrollEffect = 0x7E
    
    /// Spawn pet packet header.
    case spawnPet = 0x7F
    
    /// Move pet packet header.
    case movePet = 0x81
    
    /// Pet chat packet header.
    case petChat = 0x81_01
    
    /// Pet name change packet header.
    case petNamechange = 0x81_02
    
    /// Pet command packet header.
    case petCommand = 0x81_04
    
    /// Spawn special map object packet header.
    case spawnSpecialMapobject = 0x86
    
    /// Remove special map object packet header.
    case removeSpecialMapobject = 0x87
    
    /// Move summon packet header.
    case moveSummon = 0x88
    
    /// Summon attack packet header.
    case summonAttack = 0x89
    
    /// Damage summon packet header.
    case damageSummon = 0x8A
    
    /// Summon skill packet header.
    case summonSkill = 0x8B
    
    /// Move player packet header.
    case movePlayer = 0x8D
    
    /// Close range attack packet header.
    case closeRangeAttack = 0x8E
    
    /// Ranged attack packet header.
    case rangedAttack = 0x8F
    
    /// Magic attack packet header.
    case magicAttack = 0x90
    
    /// Skill effect packet header.
    case skillEffect = 0x92
    
    /// Cancel skill effect packet header.
    case cancelSkillEffect = 0x93
    
    /// Damage player packet header.
    case damagePlayer = 0x94
    
    /// Facial expression packet header.
    case facialExpression = 0x95
    
    /// Show item effect packet header.
    case showItemEffect = 0x95_01
    
    /// Show chair packet header.
    case showChair = 0x97
    
    /// Update character look packet header.
    case updateCharLook = 0x98
    
    /// Show foreign effect packet header.
    case showForeignEffect = 0x99
    
    /// Give foreign buff packet header.
    case giveForeignBuff = 0x9A
    
    /// Cancel foreign buff packet header.
    case cancelForeignBuff = 0x9B
    
    /// Update party member HP packet header.
    case updatePartyMemberHP = 0x9C
    
    /// Cancel chair packet header.
    case cancelChair = 0xA0
    
    /// Show item gain in chat packet header.
    case showItemGainInChat = 0xA1
    
    /// Update quest info packet header.
    case updateQuestInfo = 0xA6
    
    /// Player hint packet header.
    case playerHint = 0xA9
    
    /// Cooldown packet header.
    case cooldown = 0xAD
    
    /// Spawn monster packet header.
    case spawnMonster = 0xAF
    
    /// Kill monster packet header.
    case killMonster = 0xB0
    
    /// Spawn monster control packet header.
    case spawnMonsterControl = 0xB1
    
    /// Move monster packet header.
    case moveMonster = 0xB2
    
    /// Move monster response packet header.
    case moveMonsterResponse = 0xB3
    
    /// Damage monster packet header.
    case damageMonster = 0xB9
    
    /// Apply monster status packet header.
    case applyMonsterStatus = 0xB5
    
    /// Cancel monster status packet header.
    case cancelMonsterStatus = 0xB6
    
    /// Ariant thing packet header.
    case ariantThing = 0xBC
    
    /// Show monster HP packet header.
    case showMonsterHP = 0xBD
    
    /// Show magnet packet header.
    case showMagnet = 0xBE
    
    /// Catch monster packet header.
    case catchMonster = 0xBF
    
    /// Spawn NPC packet header.
    case spawnNPC = 0xC2
    
    /// NPC confirm packet header.
    case npcConfirm = 0xC3
    
    /// Spawn NPC request controller packet header.
    case spawnNPCRequestController = 0xC4
    
    /// NPC action packet header.
    case npcAction = 0xC5
    
    /// Update character box packet header.
    case updateCharBox = 0x7c
    
    /// Drop item from map object packet header.
    case dropItemFromMapobject = 0xCD
    
    /// Remove item from map packet header.
    case removeItemFromMap = 0xCE
    
    /// Spawn mist packet header.
    case spawnMist = 0xD2
    
    /// Remove mist packet header.
    case removeMist = 0xD3
    
    /// Spawn door packet header.
    case spawnDoor = 0xD4
    
    /// Remove door packet header.
    case removeDoor = 0xD5
    
    /// Reactor hit packet header.
    case reactorHit = 0xD6
    
    /// Reactor spawn packet header.
    case reactorSpawn = 0xD8
    
    /// Reactor destroy packet header.
    case reactorDestroy = 0xD9
    
    /// Ariant PQ start packet header.
    case ariantPqStart = 0xEA
    
    /// Zakum shrine packet header.
    case zakumShrine = 0xEC
    
    /// Boat effect packet header.
    case boatEffect = 0x6F
    
    /// Monster carnival start packet header.
    case monsterCarnivalStart = 0xE2
    
    /// Monster carnival obtained CP packet header.
    case monsterCarnivalObtainedCP = 0xE3
    
    /// Monster carnival party CP packet header.
    case monsterCarnivalPartyCP = 0xE4
    
    /// Monster carnival summon packet header.
    case monsterCarnivalSummon = 0xE5
    
    /// Monster carnival died packet header.
    case monsterCarnivalDied = 0xE7
    
    /// NPC talk packet header.
    case npcTalk = 0xED
    
    /// Open NPC shop packet header.
    case openNPCShop = 0xEE
    
    /// Confirm shop transaction packet header.
    case confirmShopTransaction = 0xEF
    
    /// Open storage packet header.
    case openStorage = 0xF0
    
    /// Messenger packet header.
    case messenger = 0xF4
    
    /// Player interaction packet header.
    case playerInteraction = 0xF5
    
    /// Duey packet header.
    case duey = 0xFD
    
    /// CS update packet header.
    case csUpdate = 0xFF
    
    /// CS operation packet header.
    case csOperation = 0x100
    
    /// Keymap packet header.
    case keymap = 0x107
    
    /// TV SMEGA packet header.
    case tvSmega = 0x10D
    
    /// Cancel TV SMEGA packet header.
    case cancelTvSmega = 0x10E
    
    /// Update mount packet header.
    case updateMount = 0x2D
    
    /// Start MTS packet header.
    case startMTS = 0x5D
    
    /// MTS open packet header.
    //case mtsOpen = 0x5D
    
    /// Get MTS tokens packet header.
    case getMTSTokens = 0x113
    
    /// MTS operation packet header.
    case mtsOperation = 0x114
    
    /// MTS operation2 packet header.
    //case mtsOperation2 = 0x0113
    
    /// Send TV packet header.
    //case sendTV = 0x10D
    
    /// Remove TV packet header.
    //case removeTV = 0x10E
    
    /// Enable TV packet header.
    case enableTV = 0x10F
    
    /// Spouse chat packet header.
    case spousechat = 0x66
    
    /// Teleport rock locations packet header.
    case trockLocations = 0x27
}

public extension MapleStory.Opcode {
    
    init(server opcode: ServerOpcode) {
        self.init(rawValue: opcode.rawValue)
    }
}
