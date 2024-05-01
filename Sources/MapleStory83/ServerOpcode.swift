//
//  ServerOpcode.swift
//  
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation

/// Represents MapleStory server packet opcodes.
public enum ServerOpcode: UInt16, Codable, CaseIterable, Sendable {
    
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
    case characterNameResponse = 0x0D
    
    /// Add new character entry opcode. (0x0E)
    case createCharacterResponse = 0x0E
    
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
        
    /// Vega scroll opcode. (0x166)
    case vegaScroll = 0x166
}

public extension MapleStory.Opcode {
    
    init(server opcode: ServerOpcode) {
        self.init(rawValue: opcode.rawValue)
    }
}
