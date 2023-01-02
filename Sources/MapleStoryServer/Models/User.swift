//
//  User.swift
//  
//
//  Created by Alsey Coleman Miller on 12/30/22.
//

import Foundation
import MapleStory
import SwiftBSON

struct User: Codable, Equatable, Hashable, Identifiable {
    
    static var collection: String { "users" }
    
    enum CodingKeys: String, CodingKey {
        
        case id = "_id"
        case username
        case password
        case created
        case pinCode = "pincode"
        case birthday
        case isAdmin = "admin"
        case connections
    }
    
    let id: BSONObjectID
    
    let username: String
    
    var password: String
    
    var created: Date
    
    var pinCode: String
    
    var birthday: Date
    
    var isAdmin: Bool
    
    var connections: [MapleStoryAddress]
    
    init(
        id: BSONObjectID = BSONObjectID(),
        username: String,
        password: String,
        created: Date = Date(),
        pinCode: String = "1234",
        birthday: Date = Date(timeIntervalSinceReferenceDate: 0),
        isAdmin: Bool = false
    ) {
        self.id = id
        self.username = username
        self.password = password
        self.created = created
        self.pinCode = pinCode
        self.birthday = birthday
        self.isAdmin = isAdmin
        self.connections = []
    }
}
