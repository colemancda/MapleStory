//
//  User.swift
//  
//
//  Created by Alsey Coleman Miller on 12/26/22.
//

import Foundation

public struct User: Codable, Equatable, Hashable, Identifiable {
    
    public let id: String
    
    public let created: Date
    
    public var password: String
    
    public var pinCode: String
    
    public var birthday: Date
    
    public var characters: [World.ID: [Character.ID]]
}
