//
//  ClientOpcode.swift
//
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation

/// Enum representing packet headers for network communication.
public enum ClientOpcode: UInt16, MapleStoryOpcode, Codable, CaseIterable, Sendable {
    
    /// Login password packet header.
    case loginRequest = 0x01
    
    /// Guest login packet header.
    case guestLoginRequest = 0x02
    
    /// Server list re-request packet header.
    case serverListRerequest = 0x04
    
    /// Character list request packet header.
    case characterListRequest = 0x05
    
    /// Server status request packet header.
    case serverStatusRequest = 0x06
    
    /// Accept Terms of Service opcode. (0x07)
    case acceptLicense = 0x07
    
    /// Set gender packet header.
    case setGender = 0x08
    
    /// After login packet header.
    case afterLogin = 0x09
    
    /// Register PIN packet header.
    case registerPIN = 0x0A
    
    /// Server list request packet header.
    case serverListRequest = 0x0B
    
    /// Player DC opcode. (0x0C)
    case playerDC = 0x0C
    
    /// View all characters packet header.
    case viewAllCharacters = 0x0D
    
    /// Pick all characters packet header.
    case pickAllCharacters = 0x0E
    
    case viewAllCharactersWorldSelected = 0x0F
    
    /// Character select packet header.
    case characterSelect = 0x13
    
    /// Player logged in packet header.
    case playerLoginRequest = 0x14
    
    /// Check char name opcode. (0x15)
    case checkCharacterName = 0x15
    
    /// Create char opcode. (0x16)
    case createCharacter = 0x16
    
    /// Delete char opcode. (0x17)
    case deleteCharacter = 0x17
    
    /// Pong opcode. (0x18)
    case pong = 0x18
    
    /// Pong opcode. (0x18)
    case clientStart = 0x19
    
    /// Strange data packet header.
    case clientError = 0x1A
    
    /// Change map packet header.
    case changeMap = 0x23
    
    /// Change channel packet header.
    case changeChannel = 0x24
    
    /// Enter cash shop packet header.
    case enterCashShop = 0x25
    
    /// Move player packet header.
    case movePlayer = 0x26
    
    /// Cancel chair packet header.
    case cancelChair = 0x27
    
    /// Use chair packet header.
    case useChair = 0x28
    
    /// Close range attack packet header.
    case closeRangeAttack = 0x29
    
    /// Ranged attack packet header.
    case rangedAttack = 0x2A
    
    /// Magic attack packet header.
    case magicAttack = 0x2B
    
    /// Take damage packet header.
    case takeDamage = 0x2D
    
    /// General chat packet header.
    case generalChat = 0x2E
    
    /// Close chalkboard packet header.
    case closeChalkboard = 0x2F
    
    /// Face expression packet header.
    case faceExpression = 0x30
    
    /// Use item effect packet header.
    case useItemEffect = 0x30_01
    
    /// NPC talk packet header.
    case npcTalk = 0x36
    
    /// NPC talk more packet header.
    case npcTalkMore = 0x38
    
    /// NPC shop packet header.
    case npcShop = 0x39
    
    /// Storage packet header.
    case storage = 0x3A
    
    /// Duey action packet header.
    case dueyAction = 0x3D
    
    /// Item sort packet header.
    case itemSort = 0x40
    
    /// Item move packet header.
    case itemMove = 0x42
    
    /// Use item packet header.
    case useItem = 0x43
    
    /// Cancel item effect packet header.
    case cancelItemEffect = 0x44
    
    /// Use summon bag packet header.
    case useSummonBag = 0x46
    
    /// Use mount food packet header.
    case useMountFood = 0x48
    
    /// Use cash item packet header.
    case useCashItem = 0x49
    
    /// Use catch item packet header.
    case useCatchItem = 0x4A
    
    /// Use skill book packet header.
    case useSkillBook = 0x4B
    
    /// Use return scroll packet header.
    case useReturnScroll = 0x4E
    
    /// Use upgrade scroll packet header.
    case useUpgradeScroll = 0x4F
    
    /// Distribute AP packet header.
    case distributeAP = 0x50
    
    /// Heal over time packet header.
    case healOverTime = 0x51
    
    /// Distribute SP packet header.
    case distributeSP = 0x52
    
    /// Special move packet header.
    case specialMove = 0x53
    
    /// Cancel buff packet header.
    case cancelBuff = 0x54
    
    /// Skill effect packet header.
    case skillEffect = 0x55
    
    /// Meso drop packet header.
    case mesoDrop = 0x56
    
    /// Give fame packet header.
    case giveFame = 0x57
    
    /// Character info request packet header.
    case charInfoRequest = 0x59
    
    /// Cancel debuff packet header.
    case cancelDebuff = 0x5B
    
    /// Change map special packet header.
    case changeMapSpecial = 0x5C
    
    /// Use inner portal packet header.
    case useInnerPortal = 0x5D
    
    /// Quest action packet header.
    case questAction = 0x62
    
    /// Skill macro packet header.
    case skillMacro = 0x65
    
    /// Report packet header.
    case report = 0x68
    
    /// Party chat packet header.
    case partyChat = 0x6B
    
    /// Whisper packet header.
    case whisper = 0x6C
    
    /// Messenger packet header.
    case messenger = 0x6E
    
    /// Player shop packet header.
    case playerShop = 0x6F
    
    /// Player interaction packet header.
    //case playerInteraction = 0x6F
    
    /// Party operation packet header.
    case partyOperation = 0x70
    
    /// Deny party request packet header.
    case denyPartyRequest = 0x71
    
    /// Guild operation packet header.
    case guildOperation = 0x72
    
    /// Deny guild request packet header.
    case denyGuildRequest = 0x73
    
    /// Buddylist modify packet header.
    case buddylistModify = 0x76
    
    /// Change keymap packet header.
    case changeKeymap = 0x7B
    
    /// BBS operation packet header.
    case bbsOperation = 0x86
    
    /// Enter MTS packet header.
    case enterMTS = 0x87
    
    /// Pet talk packet header.
    case petTalk = 0x8B
    
    /// Move summon packet header.
    case moveSummon = 0x94
    
    /// Summon attack packet header.
    case summonAttack = 0x95
    
    /// Damage summon packet header.
    case damageSummon = 0x96
    
    /// Move life packet header.
    case moveLife = 0x9D
    
    /// Auto aggro packet header.
    case autoAggro = 0x9E
    
    /// Mob damage mob packet header.
    case mobDamageMob = 0xA1
    
    /// Monster bomb packet header.
    case monsterBomb = 0xA2
    
    /// NPC action packet header.
    case npcAction = 0xA6
    
    /// Item pickup packet header.
    case itemPickup = 0xAB
    
    /// Damage reactor packet header.
    case damageReactor = 0xAE
    
    /// Monster carnival packet header.
    case monsterCarnival = 0xB9
    
    /// Party search register packet header.
    case partySearchRegister = 0xBD
    
    /// Party search start packet header.
    case partySearchStart = 0xBF
    
    /// Player update packet header.
    case playerUpdate = 0xC0
    
    /// Note action packet header.
    case noteAction = 0x77
    
    /// Use door packet header.
    case useDoor = 0x79
    
    /// Maple TV packet header.
    case mapleTV = 0xD2
    
    /// Touching CS packet header.
    case touchingCS = 0xC5
    
    /// Buy CS item packet header.
    case buyCSItem = 0xC6
    
    /// Coupon code packet header.
    case couponCode = 0xC7
    
    /// Spawn pet packet header.
    case spawnPet = 0x5A
    
    /// Move pet packet header.
    case movePet = 0x8C
    
    /// Pet chat packet header.
    case petChat = 0x8D
    
    /// Pet command packet header.
    case petCommand = 0x8E
    
    /// Pet food packet header.
    case petFood = 0x47
    
    /// Pet loot packet header.
    case petLoot = 0x8F
    
    /// MTS tab packet header.
    case mtsTab = 0xD9
    
    /// MTS operation packet header.
   // case mtsOp = 0xD9
    
    /// Ring action packet header.
    case ringAction = 0x7D
    
    /// Spouse chat packet header.
    case spousechat = 0x6D
    
    /// Pet auto pot packet header.
    case petAutoPot = 0x90
    
    /// Teleport rock add map packet header.
    case trockAddMap = 0x5E
}
