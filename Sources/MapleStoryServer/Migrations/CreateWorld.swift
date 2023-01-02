//
//  CreateWorld.swift
//  
//
//  Created by Alsey Coleman Miller on 1/2/23.
//

import Fluent

struct CreateWorld: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(World.schema)
            .id()
            .field(World.CodingKeys.index, .int, .required)
            .field(World.CodingKeys.name, .string, .required)
            .field(World.CodingKeys.address, .string, .required)
            .field(World.CodingKeys.flags, .int, .required)
            .field(World.CodingKeys.eventMessage, .string, .required)
            .field(World.CodingKeys.rateModifier, .int, .required)
            .field(World.CodingKeys.eventXP, .int, .required)
            .field(World.CodingKeys.dropRate, .int, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
      try await database
            .schema(World.schema)
            .delete()
    }
}
