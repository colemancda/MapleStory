//
//  Error.swift
//  
//
//  Created by Alsey Coleman Miller on 12/17/22.
//

import Foundation

/// MapleStory Error
public enum MapleStoryError: Error {
    
    case invalidData(Data)
    
    case disconnected(MapleStoryAddress)
    
    case notAuthenticated
}
