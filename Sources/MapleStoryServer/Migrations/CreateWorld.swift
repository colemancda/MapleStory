//
//  CreateWorld.swift
//  
//
//  Created by Alsey Coleman Miller on 1/2/23.
//

import Fluent

struct CreateWorld: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(World.schema)
            .id()
            .field(World.CodingKeys.name, .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
      database
            .schema(World.schema)
            .delete()
    }
}
