//
//  PacketOpcode.swift
//  
//
//  Created by Alsey Coleman Miller on 12/4/22.
//

/*
 List of constants defining various network packet types used in the MapleStory game. These constants are used to identify the type of network packet being sent or received by the game client or server. Each packet type has a corresponding numeric value, which is used to identify the packet when it is sent over the network. 
 */
public enum PacketOpcode: Equatable, Hashable {
    
    case request(Request)
    case response(Response)
}

extension PacketOpcode {
    
    public var rawValue: Int32 {
        switch self {
        case .request(let value):
            return value.rawValue
        case .response(let value):
            return value.rawValue
        }
    }
}

public extension PacketOpcode {
    
    enum Request: Int32, Codable {
        
        case pong = 0x18
        case loginPassword = 0x01
        case guestLogin = 0x02
        case serverListRerequest = 0x04
        case charListRequest = 0x05
        case serverStatusRequest = 0x06
        case setGender = 0x08
        case afterLogin = 0x09
        case registerPin = 0x0A
        case serverListRequest = 0x0B
        case playerDC = 0xC0
        case viewAllChar = 0x0D
        case pickAllChar = 0x0E
        case charSelect = 0x13
        //case checkCharName = 0x14
        //case createChar = 0x15
        //case deleteChar = 0x16
        case clientStart = 0x19
        case relog = 0x1C
        case playerLoggedIn = 0x14
        case strangeData = 0x1A
        case changeMap = 0x23
        case changeChannel = 0x24
        case enterCashShop = 0x25
        case movePlayer = 0x26
        case cancelChair = 0x27
        case useChair = 0x28
        case closeRangeAttack = 0x29
        case rangedAttack = 0x2A
        case magicAttack = 0x2B
        case energyOrbAttack = 0x2C
        case takeDamage = 0x2D
        case generalChat = 0x2E
        case closeChalkboard = 0x2F
        case faceExpression = 0x30
        case useItemEffect = 0x31
        case npcTalk = 0x36
        case npcTalkMore = 0x38
        case npcShop = 0x39
        case storage = 0x3A
        case hiredMerchantRequest = 0x3B
        case dueyAction = 0x3D
        case itemSort = 0x40
        case itemSort2 = 0x41
        case itemMove = 0x42
        case useItem = 0x43
        case cancelItemEffect = 0x44
        case useSummonBag = 0x46
        case useMountFood = 0x48
        case useCashItem = 0x49
        case useCatchItem = 0x4A
        case useSkillBook = 0x4B
        case useReturnScroll = 0x4E
        case useUpgradeScroll = 0x4F
        case distributeAP = 0x50
        case healOverTime = 0x51
        case distributeSP = 0x52
        case specialMove = 0x53
        case cancelBuff = 0x54
        case skillEffect = 0x55
        case mesoDrop = 0x56
        case giveFame = 0x57
        case charInfoRequest = 0x59
        case cancelDebuff = 0x5B
        case changeMapSpecial = 0x5C
        case useInnerPortal = 0x5D
        case vipAddMap = 0x5E
    }
}

public extension PacketOpcode {
    
    enum Response: Int32, Codable {
        
        case pong = 0x18
        case loginPassword = 0x01
        case guestLogin = 0x02
        case serverlistRerequest = 0x04
        case charlistRequest = 0x05
        case serverstatusRequest = 0x06
        case setGender = 0x08
        case afterLogin = 0x09
        case registerPin = 0x0A
        case serverlistRequest = 0x0B
        case playerDc = 0xC0
        case viewAllChar = 0x0D
        case pickAllChar = 0x0E
        case charSelect = 0x13
        case checkCharName = 0x15
        case createChar = 0x16
        case deleteChar = 0x17
        case clientStart = 0x19
        case relog = 0x1C
        case playerLoggedin = 0x14
        case strangeData = 0x1A
        case changeMap = 0x23
        case changeChannel = 0x24
        case enterCashShop = 0x25
        case movePlayer = 0x26
        case cancelChair = 0x27
        case useChair = 0x28
        case closeRangeAttack = 0x29
        case rangedAttack = 0x2A
        case magicAttack = 0x2B
        case energyOrbAttack = 0x2C
        case takeDamage = 0x2D
        case generalChat = 0x2E
        case closeChalkboard = 0x2F
        case faceExpression = 0x30
        case useItemeffect = 0x31
        case npcTalk = 0x36
        case npcTalkMore = 0x38
        case npcShop = 0x39
        case storage = 0x3A
        case hiredMerchantRequest = 0x3B
        case dueyAction = 0x3D
        case itemSort = 0x40
        case itemSort2 = 0x41
        case itemMove = 0x42
        case useItem = 0x43
        case cancelItemEffect = 0x44
        case useSummonBag = 0x46
        case useMountFood = 0x48
        case useCashItem = 0x49
        case useCatchItem = 0x4A
        case useSkillBook = 0x4B
        case useReturnScroll = 0x4E
        case useUpgradeScroll = 0x4F
        case distributeAp = 0x50
        case healOverTime = 0x51
        case distributeSp = 0x52
        case specialMove = 0x53
        case cancelBuff = 0x54
        case skillEffect = 0x55
        case mesoDrop = 0x56
        case giveFame = 0x57
        case charInfoRequest = 0x59
        case cancelDebuff = 0x5B
        case changeMapSpecial = 0x5C
        case useInnerPortal = 0x5D
        case vipAddMap = 0x5E
    }
}
