//
//  CreateUser.swift
//  
//
//  Created by Alsey Coleman Miller on 1/1/23.
//

import Fluent

struct CreateUser: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field(User.CodingKeys.username, .string, .required)
            .field(User.CodingKeys.password, .string, .required)
            .field(User.CodingKeys.created, .date, .required)
            .field(User.CodingKeys.pinCode, .string, .required)
            .field(User.CodingKeys.birthday, .date, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
      database
            .schema(User.schema)
            .delete()
    }
}
