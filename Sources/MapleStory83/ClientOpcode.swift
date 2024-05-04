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
    case clientStart = 0x19
    
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
    
}
