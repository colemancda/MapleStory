//
//  ServerOpcode.swift
//
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

/// Operation codes for server-client communication.
public enum ServerOpcode: UInt16, MapleStoryOpcode, Codable, CaseIterable, Sendable {
    
    /// Indicates the result of a password check.
    case checkPasswordResult = 0x01
    
    /// Retrieves the status of the game world.
    case worldStatus = 0x02
    
    /// Provides information about the game world.
    case worldInformation = 0x03
    
    /// Sends the list of characters associated with an account.
    case characterList = 0x04
    
    /// Initiates the client connection to the server for login.
    case clientConnectToServerLogin = 0x05
    
    /// Indicates the result of a character name check.
    case checkNameResult = 0x06
    
    /// Indicates the result of a character creation attempt.
    case createCharacterResult = 0x07
    
    /// Indicates the result of a character deletion attempt.
    case deleteCharacterResult = 0x08
    
    /// Initiates the client connection to the server.
    case clientConnectToServer = 0x09
    
    /// Ping operation code.
    case ping = 0x0A
    
    // Unknown codes commented out for clarity
    
    /// Inventory operation code.
    case inventoryOperation = 0x12
    
    /// Indicates a change in inventory slots.
    case inventoryChangeInventorySlots = 0x13
    
    /// Indicates changes in player statistics.
    case statsChanged = 0x14
    
    /// Buff effect granted by a skill.
    case skillsGiveBuff = 0x15
    
    /// Debuff effect applied by a skill.
    case skillsGiveDebuff = 0x16
    
    /// Indicates an increase in skill points.
    case skillsAddPoint = 0x17
    
    // Unknown codes commented out for clarity
    
    /// Indicates changes in player fame.
    case fame = 0x19
    
    /// Message operation code.
    case message = 0x1A
    
    // Unknown codes commented out for clarity
    
    /// Teleport rock operation code.
    case teleportRock = 0x1C
    
    /// Indicates the result of suing a character.
    case sueCharacterResult = 0x1D
    
    // Unknown codes commented out for clarity
    
    /// Player information operation code.
    case playerInformation = 0x1F
    
    /// Party operation code.
    case partyOperation = 0x20
    
    /// Buddy operation code.
    case buddyOperation = 0x21
    
    /// Indicates a player entering a portal to another field.
    case portalEnterField = 0x22
    
    /// Notice operation code.
    case notice = 0x23
    
    // Unknown codes commented out for clarity
    
    /// Sets the game field.
    case setField = 0x26
    
    /// Sets the cash shop field.
    case setFieldCashShop = 0x27
    
    // Unknown codes commented out for clarity
    
    /// Indicates a request to transfer to another field being ignored.
    case transferFieldReqIgnored = 0x2A
    
    /// Indicates an incorrect channel number.
    case incorrectChannelNumber = 0x2B
    
    // Unknown codes commented out for clarity
    
    /// Group message operation code.
    case groupMessage = 0x2D
    
    /// Whisper operation code.
    case whisper = 0x2E
    
    // Unknown codes commented out for clarity
    
    /// Map effect operation code.
    case mapEffect = 0x30
    
    /// Weather effect operation code.
    case weatherEffect = 0x31
    
    /// Jukebox effect operation code.
    case jukeboxEffect = 0x32
    
    /// Admin result operation code.
    case adminResult = 0x33
    
    /// GM event instructions operation code.
    case gmEventInstructions = 0x35
    
    /// Map clock operation code.
    case mapClock = 0x36
    
    /// Boat operation code.
    case boat = 0x38
    
    /// Indicates a remote player entering a field.
    case remotePlayerEnterField = 0x3C
    
    /// Indicates a remote player leaving a field.
    case remotePlayerLeaveField = 0x3D
    
    /// Indicates a chat message from a remote player.
    case remotePlayerChat = 0x3F
    
    /// Announce box operation code.
    case announceBox = 0x40
    
    /// Indicates a summon moving.
    case summonMove = 0x4B
    
    /// Indicates a summon leaving a field.
    //case summonLeaveField = 0x4B
    
    /// Indicates a summon attacking.
    case summonAttack = 0x4D
    
    /// Indicates a summon receiving damage.
    case summonDamage = 0x4E
    
    /// Indicates a remote player moving.
    case remotePlayerMove = 0x52
    
    /// Indicates a remote player performing a melee attack.
    case remotePlayerMeleeAttack = 0x53
    
    /// Indicates a remote player performing a ranged attack.
    case remotePlayerRangedAttack = 0x54
    
    /// Indicates a remote player performing a magic attack.
    case remotePlayerMagicAttack = 0x55
    
    /// Indicates a remote player receiving damage.
    case remotePlayerGetDamage = 0x58
    
    /// Indicates a remote player emoting.
    case remotePlayerEmote = 0x59
    
    /// Indicates a remote player changing equipment.
    case remotePlayerChangeEquips = 0x5A
    
    /// Indicates an effect on a remote player.
    case remotePlayerEffect = 0x5B
    
    /// Indicates a buff applied to a remote player.
    case remotePlayerSkillBuff = 0x5C
    
    /// Indicates a debuff applied to a remote player.
    case remotePlayerSkillDebuff = 0x5D
    
    /// Item effect operation code.
    case itemEffect = 0x60
    
    /// Indicates a remote player sitting on a chair.
    case remotePlayerSitOnChair = 0x61
    
    /// General effect operation code.
    case effect = 0x62
    
    /// Indicates the cash shop being unavailable.
    case cashShopUnavailable = 0x64
    
    /// Indicates the result of a meso sack operation.
    case mesoSackResult = 0x65
    
    /// Indicates a mob entering a field.
    case mobEnterField = 0x6A
    
    /// Indicates a mob leaving a field.
    case mobLeaveField = 0x6B
    
    /// Indicates a request to control a mob.
    case mobControlRequest = 0x6C
    
    /// Indicates a mob moving.
    case mobMove = 0x6E
    
    /// Indicates a response to controlling a mob.
    case mobControlResponse = 0x6F
    
    /// Indicates a change in a mob's health.
    case mobChangeHealth = 0x75
    
    /// Indicates an NPC entering a field.
    case npcEnterField = 0x7B
    
    /// Indicates an NPC leaving a field.
    case npcLeaveField = 0x7C
    
    /// Indicates a request to control an NPC.
    case npcControlRequest = 0x7D
    
    /// Indicates an NPC moving.
    case npcMove = 0x7F
    
    /// Indicates an item dropping into a field.
    case dropEnterField = 0x83
    
    /// Indicates an item leaving a field.
    case dropLeaveField = 0x84
    
    /// Indicates a message related to a kite.
    case kiteMessage = 0x87
    
    /// Indicates a kite entering a field.
    case kiteEnterField = 0x88
    
    /// Indicates a kite leaving a field.
    case kiteLeaveField = 0x89
    
    /// Indicates a mist effect entering a field.
    case mistEnterField = 0x8C
    
    /// Indicates a mist effect leaving a field.
    case mistLeaveField = 0x8D
    
    /// Indicates a door entering a field.
    case doorEnterField = 0x90
    
    /// Indicates a door leaving a field.
    case doorLeaveField = 0x91
    
    /// Indicates a change in state of a reactor.
    case reactorChangeState = 0x94
    
    /// Indicates a reactor entering a field.
    case reactorEnterField = 0x96
    
    /// Indicates a reactor leaving a field.
    case reactorLeaveField = 0x97
    
    /// Indicates the state of a snowball.
    case snowBallState = 0x9A
    
    /// Indicates a snowball hit.
    case snowBallHit = 0x9B
    
    /// Indicates a hit on a coconut.
    case coconutHit = 0x9C
    
    /// Indicates a score related to a coconut.
    case coconutScore = 0x9D
    
    /// Indicates a chat message from an NPC script.
    case npcScriptChat = 0xA0
    
    /// Indicates an NPC shop being shown.
    case npcShopShow = 0xA3
    
    /// Indicates the result of an NPC shop operation.
    case npcShopResult = 0xA4
    
    /// Indicates a storage being shown.
    case storageShow = 0xA7
    
    /// Indicates the result of a storage operation.
    case storageResult = 0xA8
    
    /// Indicates a player interaction operation.
    case playerInteraction = 0xAE
    
    /// Indicates cash shop amounts.
    case cashShopAmounts = 0xBA
    
    /// Indicates a cash shop operation.
    case cashShopOperation = 0xBB
}
