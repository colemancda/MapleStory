//
//  Fluent.swift
//  
//
//  Created by Alsey Coleman Miller on 1/1/23.
//

import Foundation
import Fluent

internal extension FieldKey {
    
    init<T: CodingKey>(_ key: T) {
        self = .string(key.stringValue)
    }
}

internal extension FieldProperty {
    
    convenience init<T: CodingKey>(key: T) {
        self.init(key: FieldKey(key))
    }
}

internal extension SchemaBuilder {
    
    @discardableResult
    func field<T: CodingKey>(
        _ key: T,
        _ dataType: DatabaseSchema.DataType,
        _ constraints: DatabaseSchema.FieldConstraint...
    ) -> Self {
        self.field(.definition(
            name: .key(.init(key)),
            dataType: dataType,
            constraints: constraints
        ))
    }
}
