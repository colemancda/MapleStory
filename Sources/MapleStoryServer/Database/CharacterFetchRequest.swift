//
//  CharacterFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory

// MARK: - Predicate

public extension Character {
    
    enum Predicate {
        
        case name(CharacterName)
        case index(Character.Index)
        case channel(Channel.ID)
        case user(User.ID)
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: Character.Predicate) {
        switch predicate {
        case .name(let name):
            self = Character.CodingKeys.id.stringValue.compare(.equalTo, [.caseInsensitive], .attribute(.string(name.rawValue)))
        case .index(let index):
            self = Character.CodingKeys.index.stringValue.compare(.equalTo, .attribute(.int64(numericCast(index))))
        case .channel(let channel):
            self = Character.CodingKeys.channel.stringValue.compare(.equalTo, .relationship(.toOne(.init(channel))))
        case .user(let user):
            self = Character.CodingKeys.user.stringValue.compare(.equalTo, .relationship(.toOne(.init(user))))
        }
    }
}
