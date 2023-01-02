//
//  CreateChannel.swift
//  
//
//  Created by Alsey Coleman Miller on 1/2/23.
//

import Fluent

struct CreateChannel: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(Channel.schema)
            .id()
            .field(Channel.CodingKeys.name, .string, .required)
            .field(Channel.CodingKeys.world, .uuid, .required, .references(World.schema, "id"))
            .field(Channel.CodingKeys.load, .int, .required)
            .field(Channel.CodingKeys.status, .uint8, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
      try await database
            .schema(Channel.schema)
            .delete()
    }
}
