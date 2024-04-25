//
//  ServerOpcode.swift
//  
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation

/// Opcode represents different types of messages or commands in a network protocol.
public enum ServerOpcode: UInt16, Codable, CaseIterable {
    
    /// Login response opcode.
    case loginResponse = 0x01
    /// Login world meta opcode.
    case loginWorldMeta = 0x03
    /// Login PIN operation opcode.
    case loginPinOperation = 0x07 // Add 1 byte, 1 = register byte a PIN
    /// Login PIN stuff opcode.
    case loginPinStuff = 0x08 // Setting byte PIN good
    /// Login world list opcode.
    case loginWorldList = 0x09
    /// Login character data opcode.
    case loginCharacterData = 0x0A
    /// Login character migrate opcode.
    case loginCharacterMigrate = 0x0B
    /// Login name check result opcode.
    case loginNameCheckResult = 0x0C
    /// Login new character good opcode.
    case loginNewCharacterGood = 0x0D
    /// Login delete character opcode.
    case loginDeleteCharacter = 0x0E
    /// Channel change opcode.
    case channelChange = 0x0F
    /// Login restarter opcode.
    case loginRestarter = 0x15
    /// Channel inventory operation opcode.
    case channelInventoryOperation = 0x18
    /// Channel stat change opcode.
    case channelStatChange = 0x1A
    /// Channel skill record update opcode.
    case channelSkillRecordUpdate = 0x1D
    /// Channel info message opcode.
    case channelInfoMessage = 0x20
    /// Channel map transfer result opcode.
    case channelMapTransferResult = 0x22
    /// Channel lie detector test opcode.
    case channelLieDetectorTest = 0x23
    /// Channel avatar info window opcode.
    case channelAvatarInfoWindow = 0x2c
    /// Channel party info opcode.
    case channelPartyInfo = 0x2D
    /// Channel buddy info opcode.
    case channelBuddyInfo = 0x2E
    /// Channel guild info opcode.
    case channelGuildInfo = 0x30
    /// Channel town portal opcode.
    case channelTownPortal = 0x31
    /// Channel broadcast message opcode.
    case channelBroadcastMessage = 0x32
    /// Channel warp to map opcode.
    case channelWarpToMap = 0x36
    /// Channel portal closed opcode.
    case channelPortalClosed = 0x3A
    /// Channel change server opcode.
    case channelChangeServer = 0x3B
    /// Channel bubble-less chat opcode.
    case channelBubblessChat = 0x3D
    /// Channel whisper opcode.
    case channelWhisper = 0x3E
    /// Channel map effect opcode.
    case channelMapEffect = 0x40
    /// Channel employee opcode.
    case channelEmployee = 0x43
    /// Channel quiz Q&A opcode.
    case channelQuizQAndA = 0x44
    /// Channel countdown opcode.
    case channelCountdown = 0x46
    /// Channel moving object opcode.
    case channelMovingObj = 0x47
    /// Channel boat opcode.
    case channelBoat = 0x48
    /// Channel character enter field opcode.
    case channelCharacterEnterField = 0x4E
    /// Channel character leave field opcode.
    case channelCharacterLeaveField = 0x4F
    /// Channel all chat message opcode.
    case channelAllChatMsg = 0x51
    /// Channel room box opcode.
    case channelRoomBox = 0x52
    /// Channel player movement opcode.
    case channelPlayerMovement = 0x65
    /// Channel player use melee skill opcode.
    case channelPlayerUseMeleeSkill = 0x66
    /// Channel player use ranged skill opcode.
    case channelPlayerUseRangedSkill = 0x67
    /// Channel player use magic skill opcode.
    case channelPlayerUseMagicSkill = 0x68
    /// Channel player take damage opcode.
    case channelPlayerTakeDmg = 0x6B
    /// Channel player emoticon opcode.
    case channelPlayerEmoticon = 0x6C
    /// Channel player change avatar opcode.
    case channelPlayerChangeAvatar = 0x6F
    /// Channel player animation opcode.
    case channelPlayerAnimation = 0x70
    /// Channel level up animation opcode.
    case channelLevelUpAnimation = 0x79
    /// Channel show mob opcode.
    case channelShowMob = 0x86
    /// Channel remove mob opcode.
    case channelRemoveMob = 0x87
    /// Channel control mob opcode.
    case channelControlMob = 0x88
    /// Channel move mob opcode.
    case channelMoveMob = 0x8A
    /// Channel control mob acknowledgement opcode.
    case channelControlMobAck = 0x8B
    /// Channel mob damage opcode.
    case channelMobDamage = 0x91
    /// Channel NPC show opcode.
    case channelNpcShow = 0x97
    /// Channel NPC remove opcode.
    case channelNpcRemove = 0x98
    /// Channel NPC control opcode.
    case channelNpcControl = 0x99
    /// Channel NPC movement opcode.
    case channelNpcMovement = 0x9B
    /// Channel drop enter map opcode.
    case channelDrobEnterMap = 0xA4
    /// Channel drop exit map opcode.
    case channelDropExitMap = 0xA5
    /// Channel spawn door opcode.
    case channelSpawnDoor = 0xB1
    /// Channel remove door opcode.
    case channelRemoveDoor = 0xB2
    /// Channel NPC dialogue box opcode.
    case channelNpcDialogueBox = 0xC5
    /// Channel NPC shop opcode.
    case channelNpcShop = 0xC8
    /// Channel NPC shop result opcode.
    case channelNpcShopResult = 0xC9
    /// Channel NPC storage opcode.
    case channelNpcStorage = 0xCD
    /// Channel room opcode.
    case channelRoom = 0xDC
}
