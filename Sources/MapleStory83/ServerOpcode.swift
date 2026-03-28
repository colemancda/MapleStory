//
//  ServerOpcode.swift
//  
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation

/// Represents MapleStory server packet opcodes.
public enum ServerOpcode: UInt16, MapleStoryOpcode, Codable, CaseIterable, Sendable {
    
    /// Login status opcode. (0x00)
    case loginStatus = 0x00
    
    /// Guest ID login opcode. (0x01)
    case guestLogin = 0x01
    
    /// Account info opcode. (0x02)
    case accountInfo = 0x02
    
    /// Server status opcode. (0x03)
    case serverStatus = 0x03
    
    /// Gender done opcode. (0x04)
    case genderDone = 0x04
    
    /// Confirm EULA result opcode. (0x05)
    case confirmEulaResult = 0x05
    
    /// Check PIN code opcode. (0x06)
    case checkPincode = 0x06
    
    /// Update PIN code opcode. (0x07)
    case updatePincode = 0x07
    
    /// View all characters opcode. (0x08)
    case viewAllCharacters = 0x08
    
    /// Select character by VAC opcode. (0x09)
    case selectCharacterByVac = 0x09
    
    /// Server list opcode. (0x0A)
    case serverList = 0x0A
    
    /// Character list opcode. (0x0B)
    case characterList = 0x0B
    
    /// Server IP opcode. (0x0C)
    case serverIP = 0x0C
    
    /// Character name response opcode. (0x0D)
    case checkCharacterNameResponse = 0x0D
    
    /// Add new character entry opcode. (0x0E)
    case CreateCharacterResponse = 0x0E
    
    /// Delete character response opcode. (0x0F)
    case deleteCharacterResponse = 0x0F
    
    /// Change channel opcode. (0x10)
    case changeChannel = 0x10
    
    /// Ping opcode. (0x11)
    case ping = 0x11
    
    /// Korean internet cafe opcode. (0x12)
    case koreanInternetCafe = 0x12
    
    /// Channel selected opcode. (0x14)
    case channelSelected = 0x14
    
    /// Hackshield request opcode. (0x15)
    case hackshieldRequest = 0x15
    
    /// Relog response opcode. (0x16)
    case relogResponse = 0x16
    
    /// Check CRC result opcode. (0x19)
    case checkCrcResult = 0x19
    
    /// Last connected world opcode. (0x1A)
    case lastConnectedWorld = 0x1A
    
    /// Recommended world message opcode. (0x1B)
    case recommendedWorldMessage = 0x1B
    
    /// Check SPW result opcode. (0x1C)
    case checkSpwResult = 0x1C

    // MARK: - CWvsContext

    /// Inventory operation opcode. (0x1D)
    case inventoryOperation = 0x1D

    /// Inventory grow opcode. (0x1E)
    case inventoryGrow = 0x1E

    /// Stat changed opcode. (0x1F)
    case statChanged = 0x1F

    /// Give buff opcode. (0x20)
    case giveBuff = 0x20

    /// Cancel buff opcode. (0x21)
    case cancelBuff = 0x21

    /// Forced stat set opcode. (0x22)
    case forcedStatSet = 0x22

    /// Forced stat reset opcode. (0x23)
    case forcedStatReset = 0x23

    /// Update skills opcode. (0x24)
    case updateSkills = 0x24

    /// Skill use result opcode. (0x25)
    case skillUseResult = 0x25

    /// Fame response opcode. (0x26)
    case fameResponse = 0x26

    /// Show status info opcode. (0x27)
    case showStatusInfo = 0x27

    /// Memo result opcode. (0x29)
    case memoResult = 0x29

    /// Quest clear opcode. (0x31)
    case questClear = 0x31

    /// Set gender opcode. (0x3A)
    case setGender = 0x3A

    /// Guild BBS packet opcode. (0x3B)
    case guildBbsPacket = 0x3B

    /// Character info opcode. (0x3D)
    case charInfo = 0x3D

    /// Party operation opcode. (0x3E)
    case partyOperation = 0x3E

    /// Buddylist opcode. (0x3F)
    case buddylist = 0x3F

    /// Guild operation opcode. (0x41)
    case guildOperation = 0x41

    /// Alliance operation opcode. (0x42)
    case allianceOperation = 0x42

    /// Spawn portal opcode. (0x43)
    case spawnPortal = 0x43

    /// Server message opcode. (0x44)
    case serverMessage = 0x44

    /// Marriage request opcode. (0x48)
    case marriageRequest = 0x48

    /// Marriage result opcode. (0x49)
    case marriageResult = 0x49

    /// Wedding gift result opcode. (0x4A)
    case weddingGiftResult = 0x4A

    /// Notify married partner map transfer opcode. (0x4B)
    case notifyMarriedPartnerMapTransfer = 0x4B

    /// Monster book set card opcode. (0x53)
    case monsterBookSetCard = 0x53

    /// Monster book set cover opcode. (0x54)
    case monsterBookSetCover = 0x54

    // MARK: - Family

    /// Family chart result opcode. (0x5E)
    case familyChartResult = 0x5E

    /// Family info result opcode. (0x5F)
    case familyInfoResult = 0x5F

    /// Family result opcode. (0x60)
    case familyResult = 0x60

    /// Family join request opcode. (0x61)
    case familyJoinRequest = 0x61

    /// Family join request result opcode. (0x62)
    case familyJoinRequestResult = 0x62

    /// Family join accepted opcode. (0x63)
    case familyJoinAccepted = 0x63

    /// Family privilege list opcode. (0x64)
    case familyPrivilegeList = 0x64

    /// Family rep gain opcode. (0x65)
    case familyRepGain = 0x65

    /// Family notify login or logout opcode. (0x66)
    case familyNotifyLoginOrLogout = 0x66

    /// Family set privilege opcode. (0x67)
    case familySetPrivilege = 0x67

    /// Family summon request opcode. (0x68)
    case familySummonRequest = 0x68

    /// Notify level up opcode. (0x69)
    case notifyLevelup = 0x69

    /// Notify job change opcode. (0x6B)
    case notifyJobChange = 0x6B

    /// New year card response opcode. (0x76)
    case newYearCardRes = 0x76

    // MARK: - CStage

    /// Set field opcode. (0x7D)
    case setField = 0x7D

    /// Set cash shop opcode. (0x7F)
    case setCashShop = 0x7F

    // MARK: - CField

    /// Set back effect opcode. (0x80)
    case setBackEffect = 0x80

    /// Blocked map opcode. (0x83)
    case blockedMap = 0x83

    /// Multichat opcode. (0x86)
    case multichat = 0x86

    /// Whisper opcode. (0x87)
    case whisper = 0x87

    /// Spouse chat opcode. (0x88)
    case spouseChat = 0x88

    /// Field effect opcode. (0x8A)
    case fieldEffect = 0x8A

    /// Blow weather opcode. (0x8E)
    case blowWeather = 0x8E

    /// Play jukebox opcode. (0x8F)
    case playJukebox = 0x8F

    /// Admin result opcode. (0x90)
    case adminResult = 0x90

    /// OX quiz opcode. (0x91)
    case oxQuiz = 0x91

    /// Clock opcode. (0x93)
    case clock = 0x93

    /// Conti move opcode. (0x94)
    case contiMove = 0x94

    /// Conti state opcode. (0x95)
    case contiState = 0x95

    /// Ariant result opcode. (0x98)
    case ariantResult = 0x98

    /// Pyramid gauge opcode. (0x9D)
    case pyramidGauge = 0x9D

    /// Pyramid score opcode. (0x9E)
    case pyramidScore = 0x9E

    /// Quickslot init opcode. (0x9F)
    case quickslotInit = 0x9F

    /// Spawn player opcode. (0xA0)
    case spawnPlayer = 0xA0

    /// Remove player from map opcode. (0xA1)
    case removePlayerFromMap = 0xA1

    /// Chat text opcode. (0xA2)
    case chattext = 0xA2

    /// Chalkboard opcode. (0xA4)
    case chalkboard = 0xA4

    /// Update character box opcode. (0xA5)
    case updateCharBox = 0xA5

    /// Show scroll effect opcode. (0xA7)
    case showScrollEffect = 0xA7

    /// Spawn pet opcode. (0xA8)
    case spawnPet = 0xA8

    /// Move pet opcode. (0xAA)
    case movePet = 0xAA

    /// Pet chat opcode. (0xAB)
    case petChat = 0xAB

    /// Pet name change opcode. (0xAC)
    case petNamechange = 0xAC

    /// Pet command opcode. (0xAE)
    case petCommand = 0xAE

    /// Spawn special map object opcode. (0xAF)
    case spawnSpecialMapobject = 0xAF

    /// Remove special map object opcode. (0xB0)
    case removeSpecialMapobject = 0xB0

    /// Move summon opcode. (0xB1)
    case moveSummon = 0xB1

    /// Summon attack opcode. (0xB2)
    case summonAttack = 0xB2

    /// Damage summon opcode. (0xB3)
    case damageSummon = 0xB3

    /// Summon skill opcode. (0xB4)
    case summonSkill = 0xB4

    /// Spawn dragon opcode. (0xB5)
    case spawnDragon = 0xB5

    /// Move dragon opcode. (0xB6)
    case moveDragon = 0xB6

    /// Remove dragon opcode. (0xB7)
    case removeDragon = 0xB7

    /// Move player opcode. (0xB9)
    case movePlayer = 0xB9

    /// Close range attack opcode. (0xBA)
    case closeRangeAttack = 0xBA

    /// Ranged attack opcode. (0xBB)
    case rangedAttack = 0xBB

    /// Magic attack opcode. (0xBC)
    case magicAttack = 0xBC

    /// Energy attack opcode. (0xBD)
    case energyAttack = 0xBD

    /// Skill effect opcode. (0xBE)
    case skillEffect = 0xBE

    /// Cancel skill effect opcode. (0xBF)
    case cancelSkillEffect = 0xBF

    /// Damage player opcode. (0xC0)
    case damagePlayer = 0xC0

    /// Facial expression opcode. (0xC1)
    case facialExpression = 0xC1

    /// Show item effect opcode. (0xC2)
    case showItemEffect = 0xC2

    /// Show chair opcode. (0xC4)
    case showChair = 0xC4

    /// Update character look opcode. (0xC5)
    case updateCharLook = 0xC5

    /// Show foreign effect opcode. (0xC6)
    case showForeignEffect = 0xC6

    /// Give foreign buff opcode. (0xC7)
    case giveForeignBuff = 0xC7

    /// Cancel foreign buff opcode. (0xC8)
    case cancelForeignBuff = 0xC8

    /// Update party member HP opcode. (0xC9)
    case updatePartyMemberHP = 0xC9

    /// Cancel chair opcode. (0xCD)
    case cancelChair = 0xCD

    /// Show item gain in chat opcode. (0xCE)
    case showItemGainInChat = 0xCE

    /// Update quest info opcode. (0xD3)
    case updateQuestInfo = 0xD3

    /// Maker result opcode. (0xD9)
    case makerResult = 0xD9

    /// Show combo opcode. (0xE1)
    case showCombo = 0xE1

    /// Cooldown opcode. (0xEA)
    case cooldown = 0xEA

    // MARK: - Monsters / NPCs

    /// Spawn monster opcode. (0xEC)
    case spawnMonster = 0xEC

    /// Kill monster opcode. (0xED)
    case killMonster = 0xED

    /// Spawn monster control opcode. (0xEE)
    case spawnMonsterControl = 0xEE

    /// Move monster opcode. (0xEF)
    case moveMonster = 0xEF

    /// Move monster response opcode. (0xF0)
    case moveMonsterResponse = 0xF0

    /// Apply monster status opcode. (0xF2)
    case applyMonsterStatus = 0xF2

    /// Cancel monster status opcode. (0xF3)
    case cancelMonsterStatus = 0xF3

    /// Damage monster opcode. (0xF6)
    case damageMonster = 0xF6

    /// Show monster HP opcode. (0xFA)
    case showMonsterHP = 0xFA

    /// Catch monster opcode. (0xFB)
    case catchMonster = 0xFB

    /// Show magnet opcode. (0xFD)
    case showMagnet = 0xFD

    /// Spawn NPC opcode. (0x101)
    case spawnNPC = 0x101

    /// Remove NPC opcode. (0x102)
    case removeNPC = 0x102

    /// Spawn NPC request controller opcode. (0x103)
    case spawnNPCRequestController = 0x103

    /// NPC action opcode. (0x104)
    case npcAction = 0x104

    /// Spawn hired merchant opcode. (0x109)
    case spawnHiredMerchant = 0x109

    /// Destroy hired merchant opcode. (0x10A)
    case destroyHiredMerchant = 0x10A

    // MARK: - Map Objects

    /// Drop item from map object opcode. (0x10C)
    case dropItemFromMapobject = 0x10C

    /// Remove item from map opcode. (0x10D)
    case removeItemFromMap = 0x10D

    /// Spawn mist opcode. (0x111)
    case spawnMist = 0x111

    /// Remove mist opcode. (0x112)
    case removeMist = 0x112

    /// Spawn door opcode. (0x113)
    case spawnDoor = 0x113

    /// Remove door opcode. (0x114)
    case removeDoor = 0x114

    /// Reactor hit opcode. (0x115)
    case reactorHit = 0x115

    /// Reactor spawn opcode. (0x117)
    case reactorSpawn = 0x117

    /// Reactor destroy opcode. (0x118)
    case reactorDestroy = 0x118

    // MARK: - Events / Minigames

    /// Snowball state opcode. (0x119)
    case snowballState = 0x119

    /// Coconut hit opcode. (0x11D)
    case coconutHit = 0x11D

    /// Coconut score opcode. (0x11E)
    case coconutScore = 0x11E

    /// Monster carnival start opcode. (0x121)
    case monsterCarnivalStart = 0x121

    /// Monster carnival obtained CP opcode. (0x122)
    case monsterCarnivalObtainedCP = 0x122

    /// Monster carnival party CP opcode. (0x123)
    case monsterCarnivalPartyCP = 0x123

    /// Monster carnival summon opcode. (0x124)
    case monsterCarnivalSummon = 0x124

    /// Monster carnival message opcode. (0x125)
    case monsterCarnivalMessage = 0x125

    /// Monster carnival died opcode. (0x126)
    case monsterCarnivalDied = 0x126

    /// Monster carnival leave opcode. (0x127)
    case monsterCarnivalLeave = 0x127

    // MARK: - NPC / Shop / Storage

    /// NPC talk opcode. (0x130)
    case npcTalk = 0x130

    /// Open NPC shop opcode. (0x131)
    case openNPCShop = 0x131

    /// Confirm shop transaction opcode. (0x132)
    case confirmShopTransaction = 0x132

    /// Storage opcode. (0x135)
    case storage = 0x135

    /// Fredrick opcode. (0x137)
    case fredrick = 0x137

    /// Messenger opcode. (0x139)
    case messenger = 0x139

    /// Player interaction opcode. (0x13A)
    case playerInteraction = 0x13A

    // MARK: - Wedding

    /// Wedding progress opcode. (0x140)
    case weddingProgress = 0x140

    /// Wedding ceremony end opcode. (0x141)
    case weddingCeremonyEnd = 0x141

    /// Parcel opcode. (0x142)
    case parcel = 0x142

    // MARK: - Cash Shop

    /// Charge param result opcode. (0x143)
    case chargeParamResult = 0x143

    /// Query cash result opcode. (0x144)
    case queryCashResult = 0x144

    /// Cash shop operation opcode. (0x145)
    case cashshopOperation = 0x145

    /// Keymap opcode. (0x14F)
    case keymap = 0x14F

    // MARK: - MTS

    /// MTS operation2 opcode. (0x15B)
    case mtsOperation2 = 0x15B

    /// MTS operation opcode. (0x15C)
    case mtsOperation = 0x15C

    /// Vicious hammer opcode. (0x162)
    case viciousHammer = 0x162

    /// Vega scroll opcode. (0x166)
    case vegaScroll = 0x166
}
