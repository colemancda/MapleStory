//
//  ClientOpcode.swift
//
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation

/// Represents MapleStory client packet opcodes.
public enum ClientOpcode: UInt16, MapleStoryOpcode, Codable, CaseIterable, Sendable {
    
    /// Login password opcode. (0x01)
    case loginRequest = 0x01
    
    /// Guest login opcode. (0x02)
    case guestLoginRequest = 0x02
    
    /// Serverlist rerequest opcode. (0x04)
    case serverListRerequest = 0x04
    
    /// Charlist request opcode. (0x05)
    case characterListRequest = 0x05
    
    /// Serverstatus request opcode. (0x06)
    case serverStatusRequest = 0x06
    
    /// Accept Terms of Service opcode. (0x07)
    case acceptLicense = 0x07
    
    /// Set gender opcode. (0x08)
    case setGender = 0x08
    
    /// After login opcode. (0x09)
    case afterLogin = 0x09
    
    /// Register PIN opcode. (0x0A)
    case registerPIN = 0x0A
    
    /// Serverlist request opcode. (0x0B)
    case serverListRequest = 0x0B
    
    /// Player DC opcode. (0x0C)
    case playerDC = 0x0C
    
    /// View all char opcode. (0x0D)
    case viewAllCharacters = 0x0D
    
    /// Unknown character (0x0F)
    case viewAllCharactersWorldSelected = 0x0F
    
    /// Pick all char opcode. (0x0E)
    case pickAllCharacters = 0x0E
    
    /// Name transfer opcode. (0x10)
    case nameTransfer = 0x10
    
    /// World transfer opcode. (0x12)
    case worldTransfer = 0x12
    
    /// Char select opcode. (0x13)
    case characterSelectRequest = 0x13
    
    /// Player loggedin opcode. (0x14)
    case playerLoginRequest = 0x14
    
    /// Check char name opcode. (0x15)
    case checkCharacterName = 0x15
    
    /// Create char opcode. (0x16)
    case createCharacter = 0x16
    
    /// Delete char opcode. (0x17)
    case deleteCharacter = 0x17
    
    /// Pong opcode. (0x18)
    case pong = 0x18
    
    /// Client start error opcode. (0x19)
    case clientStartError = 0x19
    
    /// Client error opcode. (0x1A)
    case clientError = 0x1A
    
    /// Strange data opcode. (0x1B)
    case strangeData = 0x1B
    
    /// Relog opcode. (0x1C)
    case relog = 0x1C
    
    /// Register PIC opcode. (0x1D)
    case registerPIC = 0x1D
    
    /// Char select with PIC opcode. (0x1E)
    case charSelectWithPIC = 0x1E
    
    /// View all PIC register opcode. (0x1F)
    case viewAllPICRegister = 0x1F
    
    /// View all with PIC opcode. (0x20)
    case viewAllWithPIC = 0x20
    
    case unknownClientStart = 0x23
    
    /// Change map opcode. (0x26)
    case changeMap = 0x26
    
    /// Change channel opcode. (0x27)
    case changeChannel = 0x27
    
    /// Enter cashshop opcode. (0x28)
    case enterCashshop = 0x28
    
    /// Move player opcode. (0x29)
    case movePlayer = 0x29
    
    /// Cancel chair opcode. (0x2A)
    case cancelChair = 0x2A
    
    /// Use chair opcode. (0x2B)
    case useChair = 0x2B
    
    /// Close range attack opcode. (0x2C)
    case closeRangeAttack = 0x2C
    
    /// Ranged attack opcode. (0x2D)
    case rangedAttack = 0x2D
    
    /// Magic attack opcode. (0x2E)
    case magicAttack = 0x2E
    
    /// Touch monster attack opcode. (0x2F)
    case touchMonsterAttack = 0x2F
    
    /// Take damage opcode. (0x30)
    case takeDamage = 0x30
    
    /// General chat opcode. (0x31)
    case generalChat = 0x31
    
    /// Close chalkboard opcode. (0x32)
    case closeChalkboard = 0x32
    
    /// Face expression opcode. (0x33)
    case faceExpression = 0x33
    
    /// Use item effect opcode. (0x34)
    case useItemEffect = 0x34
    
    /// Use death item opcode. (0x35)
    case useDeathItem = 0x35
    
    /// Mob banish player opcode. (0x38)
    case mobBanishPlayer = 0x38
    
    /// Monster book cover opcode. (0x39)
    case monsterBookCover = 0x39
    
    /// NPC talk opcode. (0x3A)
    case NPCTalk = 0x3A
    
    /// Remote store opcode. (0x3B)
    case remoteStore = 0x3B
    
    /// NPC talk more opcode. (0x3C)
    case NPCTalkMore = 0x3C
    
    /// NPC shop opcode. (0x3D)
    case NPCShop = 0x3D
    
    /// Storage opcode. (0x3E)
    case storage = 0x3E
    
    /// Hired merchant request opcode. (0x3F)
    case hiredMerchantRequest = 0x3F
    
    /// Fredrick action opcode. (0x40)
    case FredrickAction = 0x40
    
    /// Duey action opcode. (0x41)
    case DueyAction = 0x41
    
    /// Owl action opcode. (0x42)
    case OwlAction = 0x42
    
    /// Owl warp opcode. (0x43)
    case OwlWarp = 0x43
    
    /// Admin shop opcode. (0x44)
    case adminShop = 0x44
    
    /// Item sort opcode. (0x45)
    case itemSort = 0x45
    
    /// Item sort2 opcode. (0x46)
    case itemSort2 = 0x46
    
    /// Item move opcode. (0x47)
    case itemMove = 0x47
    
    /// Use item opcode. (0x48)
    case useItem = 0x48
    
    /// Cancel item effect opcode. (0x49)
    case cancelItemEffect = 0x49
    
    /// Use summon bag opcode. (0x4B)
    case useSummonBag = 0x4B
    
    /// Pet food opcode. (0x4C)
    case petFood = 0x4C
    
    /// Use mount food opcode. (0x4D)
    case useMountFood = 0x4D
    
    /// Scripted item opcode. (0x4E)
    case scriptedItem = 0x4E
    
    /// Use cash item opcode. (0x4F)
    case useCashItem = 0x4F

    /// Use catch item opcode. (0x51)
    case useCatchItem = 0x51

    /// Use skill book opcode. (0x52)
    case useSkillBook = 0x52

    /// Use teleport rock opcode. (0x54)
    case useTeleportRock = 0x54

    /// Use return scroll opcode. (0x55)
    case useReturnScroll = 0x55

    /// Use upgrade scroll opcode. (0x56)
    case useUpgradeScroll = 0x56

    /// Distribute AP opcode. (0x57)
    case distributeAP = 0x57

    /// Auto distribute AP opcode. (0x58)
    case autoDistributeAP = 0x58

    /// Heal over time opcode. (0x59)
    case healOverTime = 0x59

    /// Distribute SP opcode. (0x5A)
    case distributeSP = 0x5A

    /// Special move opcode. (0x5B)
    case specialMove = 0x5B

    /// Cancel buff opcode. (0x5C)
    case cancelBuff = 0x5C

    /// Skill effect opcode. (0x5D)
    case skillEffect = 0x5D

    /// Meso drop opcode. (0x5E)
    case mesoDrop = 0x5E

    /// Give fame opcode. (0x5F)
    case giveFame = 0x5F

    /// Character info request opcode. (0x61)
    case charInfoRequest = 0x61

    /// Spawn pet opcode. (0x62)
    case spawnPet = 0x62

    /// Cancel debuff opcode. (0x63)
    case cancelDebuff = 0x63

    /// Change map special opcode. (0x64)
    case changeMapSpecial = 0x64

    /// Use inner portal opcode. (0x65)
    case useInnerPortal = 0x65

    /// Teleport rock add map opcode. (0x66)
    case trockAddMap = 0x66

    /// Report opcode. (0x6A)
    case report = 0x6A

    /// Quest action opcode. (0x6B)
    case questAction = 0x6B

    /// Grenade effect opcode. (0x6D)
    case grenadeEffect = 0x6D

    /// Skill macro opcode. (0x6E)
    case skillMacro = 0x6E

    /// Use item reward opcode. (0x70)
    case useItemReward = 0x70

    /// Maker skill opcode. (0x71)
    case makerSkill = 0x71

    /// Use remote opcode. (0x74)
    case useRemote = 0x74

    /// Water of life opcode. (0x75)
    case waterOfLife = 0x75

    /// Admin chat opcode. (0x76)
    case adminChat = 0x76

    /// Multi chat opcode. (0x77)
    case multiChat = 0x77

    /// Whisper opcode. (0x78)
    case whisper = 0x78

    /// Spouse chat opcode. (0x79)
    case spouseChat = 0x79

    /// Messenger opcode. (0x7A)
    case messenger = 0x7A

    /// Player interaction opcode. (0x7B)
    case playerInteraction = 0x7B

    /// Party operation opcode. (0x7C)
    case partyOperation = 0x7C

    /// Deny party request opcode. (0x7D)
    case denyPartyRequest = 0x7D

    /// Guild operation opcode. (0x7E)
    case guildOperation = 0x7E

    /// Deny guild request opcode. (0x7F)
    case denyGuildRequest = 0x7F

    /// Admin command opcode. (0x80)
    case adminCommand = 0x80

    /// Admin log opcode. (0x81)
    case adminLog = 0x81

    /// Buddylist modify opcode. (0x82)
    case buddylistModify = 0x82

    /// Note action opcode. (0x83)
    case noteAction = 0x83

    /// Use door opcode. (0x85)
    case useDoor = 0x85

    /// Change keymap opcode. (0x87)
    case changeKeymap = 0x87

    /// RPS action opcode. (0x88)
    case rpsAction = 0x88

    /// Ring action opcode. (0x89)
    case ringAction = 0x89

    /// Wedding action opcode. (0x8A)
    case weddingAction = 0x8A

    /// Wedding talk opcode. (0x8B)
    case weddingTalk = 0x8B

    /// Alliance operation opcode. (0x8F)
    case allianceOperation = 0x8F

    /// Deny alliance request opcode. (0x90)
    case denyAllianceRequest = 0x90

    /// Open family pedigree opcode. (0x91)
    case openFamilyPedigree = 0x91

    /// Open family opcode. (0x92)
    case openFamily = 0x92

    /// Add family opcode. (0x93)
    case addFamily = 0x93

    /// Separate family by senior opcode. (0x94)
    case separateFamilyBySenior = 0x94

    /// Separate family by junior opcode. (0x95)
    case separateFamilyByJunior = 0x95

    /// Accept family opcode. (0x96)
    case acceptFamily = 0x96

    /// Use family opcode. (0x97)
    case useFamily = 0x97

    /// Change family message opcode. (0x98)
    case changeFamilyMessage = 0x98

    /// Family summon response opcode. (0x99)
    case familySummonResponse = 0x99

    /// BBS operation opcode. (0x9B)
    case bbsOperation = 0x9B

    /// Enter MTS opcode. (0x9C)
    case enterMTS = 0x9C

    /// Use Solomon item opcode. (0x9D)
    case useSolomonItem = 0x9D

    /// Use Gacha EXP opcode. (0x9E)
    case useGachaExp = 0x9E

    /// New year card request opcode. (0x9F)
    case newYearCardRequest = 0x9F

    /// Cash shop surprise opcode. (0xA1)
    case cashshopSurprise = 0xA1

    /// Click guide opcode. (0xA2)
    case clickGuide = 0xA2

    /// Aran combo counter opcode. (0xA3)
    case aranComboCounter = 0xA3

    /// Move pet opcode. (0xA7)
    case movePet = 0xA7

    /// Pet chat opcode. (0xA8)
    case petChat = 0xA8

    /// Pet command opcode. (0xA9)
    case petCommand = 0xA9

    /// Pet loot opcode. (0xAA)
    case petLoot = 0xAA

    /// Pet auto pot opcode. (0xAB)
    case petAutoPot = 0xAB

    /// Pet exclude items opcode. (0xAC)
    case petExcludeItems = 0xAC

    /// Move summon opcode. (0xAF)
    case moveSummon = 0xAF

    /// Summon attack opcode. (0xB0)
    case summonAttack = 0xB0

    /// Damage summon opcode. (0xB1)
    case damageSummon = 0xB1

    /// Beholder opcode. (0xB2)
    case beholder = 0xB2

    /// Move dragon opcode. (0xB5)
    case moveDragon = 0xB5

    /// Change quickslot opcode. (0xB7)
    case changeQuickslot = 0xB7

    /// Move life opcode. (0xBC)
    case moveLife = 0xBC

    /// Auto aggro opcode. (0xBD)
    case autoAggro = 0xBD

    /// Field damage mob opcode. (0xBF)
    case fieldDamageMob = 0xBF

    /// Mob damage mob friendly opcode. (0xC0)
    case mobDamageMobFriendly = 0xC0

    /// Monster bomb opcode. (0xC1)
    case monsterBomb = 0xC1

    /// Mob damage mob opcode. (0xC2)
    case mobDamageMob = 0xC2

    /// NPC action opcode. (0xC5)
    case npcAction = 0xC5

    /// Item pickup opcode. (0xCA)
    case itemPickup = 0xCA

    /// Damage reactor opcode. (0xCD)
    case damageReactor = 0xCD

    /// Touching reactor opcode. (0xCE)
    case touchingReactor = 0xCE

    /// Player map transfer opcode. (0xCF)
    case playerMapTransfer = 0xCF

    /// Snowball opcode. (0xD3)
    case snowball = 0xD3

    /// Left knockback opcode. (0xD4)
    case leftKnockback = 0xD4

    /// Coconut opcode. (0xD5)
    case coconut = 0xD5

    /// Monster carnival opcode. (0xDA)
    case monsterCarnival = 0xDA

    /// Party search register opcode. (0xDC)
    case partySearchRegister = 0xDC

    /// Party search start opcode. (0xDE)
    case partySearchStart = 0xDE

    /// Party search update opcode. (0xDF)
    case partySearchUpdate = 0xDF

    /// Check cash opcode. (0xE4)
    case checkCash = 0xE4

    /// Cash shop operation opcode. (0xE5)
    case cashshopOperation = 0xE5

    /// Coupon code opcode. (0xE6)
    case couponCode = 0xE6

    /// Open item UI opcode. (0xEC)
    case openItemUI = 0xEC

    /// Close item UI opcode. (0xED)
    case closeItemUI = 0xED

    /// Use item UI opcode. (0xEE)
    case useItemUI = 0xEE

    /// MTS operation opcode. (0xFD)
    case mtsOperation = 0xFD

    /// Use MapleLife opcode. (0x100)
    case useMapleLife = 0x100

    /// Use hammer opcode. (0x104)
    case useHammer = 0x104

}
