//
//  Error.swift
//  
//
//  Created by Alsey Coleman Miller on 12/17/22.
//

import Foundation

/// MapleStory Error
public enum MapleStoryError: Error {
    
    case invalidAddress(String)
    
    case disconnected(MapleStoryAddress)
        
    case invalidData(Data)
    
    case notAuthenticated
    
    case unknownUser(String)
    
    case invalidPassword
}
