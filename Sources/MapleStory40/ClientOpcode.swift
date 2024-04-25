//
//  ClientOpcode.swift
//
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

/// Operation codes for client-server communication.
public enum ClientOpcode: UInt16, Codable, CaseIterable {
    
    /// Initiates the login process.
    case login = 0x01
    
    /// Allows the client to select a game channel.
    case selectChannel = 0x02
    
    /// Retrieves the status of the game world.
    case worldStatus = 0x03
    
    /// Selects a character to play.
    case selectCharacter = 0x04
    
    /// Loads character data.
    case characterLoad = 0x05
    
    /// Checks the availability of a character name.
    case checkName = 0x06
    
    /// Initiates the character creation process.
    case createCharacter = 0x07
    
    /// Deletes a character.
    case deleteCharacter = 0x08
    
    /// A response to a ping from the server.
    case pong = 0x09
    
    /// Reports a client crash to the server.
    case clientCrashReport = 0x0A
    
    /// Sends client hash information to the server.
    case clientHash = 0x0E
    
    /// Changes the game field.
    case changeField = 0x11
    
    /// Changes the game channel.
    case changeChannel = 0x12
    
    /// Connects to the cash shop from the game field.
    case fieldConnectCashShop = 0x13
    
    /// Player movement.
    case playerMovement = 0x14
    
    /// Player sits on a map chair in the game field.
    case fieldPlayerSitMapChair = 0x15
    
    /// Melee attack.
    case attackMelee = 0x16
    
    /// Ranged attack.
    case attackRanged = 0x17
    
    /// Magic attack.
    case attackMagic = 0x18
    
    /// Player takes damage.
    case takeDamage = 0x1A
    
    /// Player chat message.
    case playerChat = 0x1B
    
    /// Changes the player's face expression.
    case faceExpression = 0x1C
    
    /// Selects an NPC.
    case npcSelect = 0x1F
    
    /// NPC chat message.
    case npcChat = 0x20
    
    /// Opens an NPC shop.
    case npcShop = 0x21
    
    /// Opens NPC storage.
    case npcStorage = 0x22
    
    /// Changes an item's slot in the inventory.
    case inventoryChangeSlot = 0x23
    
    /// Uses an item.
    case useItem = 0x24
    
    /// Uses a summoning bag.
    case useSummonBag = 0x25
    
    /// Uses a cash item.
    case useCashItem = 0x27
    
    /// Uses a return scroll.
    case useReturnScroll = 0x28
    
    /// Uses a scroll on an item in the inventory.
    case inventoryUseScrollOnItem = 0x29
    
    /// Distributes ability points.
    case distributeAp = 0x2A
    
    /// Heals over time.
    case healOverTime = 0x2B
    
    /// Distributes skill points.
    case distributeSp = 0x2C
    
    /// Uses a skill.
    case skillUse = 0x2D
    
    /// Stops using a skill.
    case skillStop = 0x2E
    
    /// Drops mesos.
    case mesoDrop = 0x30
    
    /// Modifies player fame.
    case remoteModifyFame = 0x31
    
    /// Requests player information.
    case playerInformation = 0x33
    
    /// Pet enters the game field.
    case petEnterField = 0x34
    
    /// Uses an inner portal.
    case useInnerPortal = 0x36
    
    /// Uses a teleport rock.
    case teleportRockUse = 0x37
    
    /// Reports a player.
    case reportPlayer = 0x38
    
    /// Sends an admin command message.
    case adminCommandMessage = 0x3A
    
    /// Sends a message to multiple players.
    case multiChat = 0x3B
    
    /// Finds a player to whisper to.
    case commandWhisperFind = 0x3C
    
    /// Sends a message in the CUI messenger.
    case cuiMessenger = 0x3D
    
    /// Interacts with another player (e.g., miniroom).
    case playerInteraction = 0x3E
    
    /// Creates a party.
    case partyCreate = 0x3F
    
    /// Sends a message within a party.
    case partyMessage = 0x40
    
    /// Sends an admin command.
    case adminCommand = 0x41
    
    /// Logs an admin command.
    case adminCommandLog = 0x42
    
    /// Handles buddy-related actions.
    case buddy = 0x43
    
    /// Creates a mystic door.
    case mysticDoor = 0x45
    
    /// Moves a pet.
    case petMove = 0x48
    
    /// Sends a chat message from a pet.
    case petChat = 0x49
    
    /// Performs an action with a pet.
    case petAction = 0x4A
    
    /// Loots items with a pet.
    case petLoot = 0x4B
    
    /// Moves a summon.
    case summonMove = 0x4E
    
    /// Attacks with a summon.
    case summonAttack = 0x4F
    
    /// Deals damage with a summon.
    case summonDamage = 0x50
    
    /// Mob movement.
    case mobMovement = 0x56
    
    /// Distance between mob and player.
    case mobDistanceFromPlayer = 0x57
    
    /// Picks up or drops items by mobs.
    case mobPickupDrop = 0x58
    
    /// NPC movement.
    case npcMovement = 0x5B
    
    /// Picks up dropped items.
    case dropPickup = 0x5F
    
    /// Starts an admin event.
    case adminEventStart = 0x65
    
    /// Coconut event.
    case coconutEvent = 0x68
    
    /// Resets an admin event.
    case adminEventReset = 0x6A
    
    /// Requests boat status.
    case boatStatusRequest = 0x70
    
    /// Represents an unknown operation code.
    case unknown = 0xFF
}
