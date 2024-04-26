//
//  Model.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel

public extension Model {
    
    static let mapleStory = Model(
        entities: 
            User.self,
            World.self,
            Channel.self,
            Character.self
    )
}
