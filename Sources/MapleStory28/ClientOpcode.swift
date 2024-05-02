//
//  ClientOpcode.swift
//
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation

/// Opcode represents different types of messages or commands in a network protocol.
public enum ClientOpcode: UInt8, CaseIterable, MapleStoryOpcode, Sendable {
    
    /// Login request opcode.
    case loginRequest = 0x01
    /// Login channel select opcode.
    case loginChannelSelect = 0x04
    /// Accept Terms of Service opcode. (0x06)
    case acceptLicense = 0x06
    /// Login world select opcode.
    case loginWorldSelect = 0x05
    /// Login check login opcode.
    case loginCheckLogin = 0x08
    /// Login register pin opcode.
    case loginRegisterPin = 0x09
    /// Login select character opcode.
    case loginSelectCharacter = 0x0B
    /// Channel player load opcode.
    case channelPlayerLoad = 0x0C
    /// Login name check opcode.
    case loginNameCheck = 0x0D
    /// Login new character opcode.
    case loginNewCharacter = 0x0E
    /// Login delete character opcode.
    case loginDeleteChar = 0x0F
    /// Ping opcode.
    case ping = 0x12
    /// Return to login screen opcode.
    case returnToLoginScreen = 0x14
    /// Channel user portal opcode.
    case channelUserPortal = 0x17
    /// Channel change channel opcode.
    case channelChangeChannel = 0x18
    /// Channel enter cash shop opcode.
    case channelEnterCashShop = 0x19
    /// Channel player movement opcode.
    case channelPlayerMovement = 0x1A
    /// Channel player stand opcode.
    case channelPlayerStand = 0x1B
    /// Channel player use chair opcode.
    case channelPlayerUseChair = 0x1C
    /// Channel melee skill opcode.
    case channelMeleeSkill = 0x1D
    /// Channel ranged skill opcode.
    case channelRangedSkill = 0x1E
    /// Channel magic skill opcode.
    case channelMagicSkill = 0x1F
    /// Channel damage received opcode.
    case channelDmgRecv = 0x21
    /// Channel player send all chat opcode.
    case channelPlayerSendAllChat = 0x22
    /// Channel emote opcode.
    case channelEmote = 0x23
    /// Channel NPC dialogue opcode.
    case channelNpcDialogue = 0x27
    /// Channel NPC dialogue continue opcode.
    case channelNpcDialogueContinue = 0x28
    /// Channel NPC shop opcode.
    case channelNpcShop = 0x29
    /// Channel inventory move item opcode.
    case channelInvMoveItem = 0x2D
    /// Channel inventory use item opcode.
    case channelInvUseItem = 0x2E
    /// Channel add stat point opcode.
    case channelAddStatPoint = 0x36
    /// Channel passive regeneration opcode.
    case channelPassiveRegen = 0x37
    /// Channel add skill point opcode.
    case channelAddSkillPoint = 0x38
    /// Channel special skill opcode.
    case channelSpecialSkill = 0x39
    /// Channel player drop mesos opcode.
    case channelPlayerDropMesos = 0x3C
    /// Channel character info opcode.
    case channelCharacterInfo = 0x3F
    /// Channel lie detector result opcode.
    case channelLieDetectorResult = 0x45
    /// Channel character report opcode.
    case channelCharacterReport = 0x49
    /// Channel group chat opcode.
    case channelGroupChat = 0x4B
    /// Channel slash commands opcode.
    case channelSlashCommands = 0x4C
    /// Channel character UI window opcode.
    case channelCharacterUIWindow = 0x4E
    /// Channel party info opcode.
    case channelPartyInfo = 0x4F
    /// Channel guild management opcode.
    case channelGuildManagement = 0x51
    /// Channel guild reject opcode.
    case channelGuildReject = 0x52
    /// Channel buddy operation opcode.
    case channelBuddyOperation = 0x55
    /// Channel use mystic door opcode.
    case channelUseMysticDoor = 0x58
    /// Channel mob control opcode.
    case channelMobControl = 0x6A
    /// Channel distance opcode.
    case channelDistance = 0x6B
    /// Channel NPC movement opcode.
    case channelNpcMovement = 0x6F
    /// Channel player pickup opcode.
    case channelPlayerPickup = 0x73
    /// Channel boat map opcode.
    case channelBoatMap = 0x80
}
