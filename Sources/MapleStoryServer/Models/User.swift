//
//  User.swift
//  
//
//  Created by Alsey Coleman Miller on 12/30/22.
//

import Foundation
import Vapor
import Fluent

final class User: Model, Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case username
        case password
        case created
        case pinCode = "pincode"
        case birthday
    }
    
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: CodingKeys.username)
    var username: String
    
    @Field(key: CodingKeys.password)
    var password: String
    
    @Field(key: CodingKeys.created)
    var created: Date
    
    @Field(key: CodingKeys.pinCode)
    var pinCode: String
    
    @Field(key: CodingKeys.birthday)
    var birthday: Date
    
    init() { }
    
    init(
        id: UUID? = nil,
        username: String,
        password: String,
        created: Date = Date(),
        pinCode: String = "1234",
        birthday: Date = Date(timeIntervalSinceReferenceDate: 0)
    ) {
        self.id = id
        self.username = username
        self.password = password
        self.created = created
        self.pinCode = pinCode
        self.birthday = birthday
    }
}
