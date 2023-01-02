//
//  Character.swift
//  
//
//  Created by Alsey Coleman Miller on 1/2/23.
//

import Foundation
import Fluent

final class Character: Model, Codable {
    
    static let schema = "characters"
    
    @ID
    var id: UUID?
    
    
}
