//
//  NPCScript.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStoryServer
import Socket
import CoreModel
import MongoSwift
import MongoDBModel

/// An NPC script is an async function that receives a context and drives
/// the conversation by calling the context's `send*` methods.
public typealias NPCScript<Socket: MapleStorySocket, Database: ModelStorage> = @Sendable (NPCScriptContext<Socket, Database>) async throws -> Void

/// Registry that maps NPC template IDs to their scripts.
///
/// Register scripts at startup (e.g. in `ChannelServerCommand.run()`):
/// ```swift
/// NPCScriptRegistry.shared.register(npc: 1012100) { ctx in
///     try await ctx.sendOk("Hello, traveller!")
/// }
/// ```
public final class NPCScriptRegistry<Socket: MapleStorySocket, Database: ModelStorage>: @unchecked Sendable {

    private var scripts = [UInt32: NPCScript<Socket, Database>]()

    private let lock = NSLock()

    public init() { }

    public func register(npc id: UInt32, _ script: @escaping NPCScript<Socket, Database>) {
        lock.withLock { scripts[id] = script }
    }

    public func script(for npcID: UInt32) -> NPCScript<Socket, Database>? {
        lock.withLock { scripts[npcID] }
    }
}

/// Shared v62 NPC script registry instance.
public let NPCScriptRegistryShared = NPCScriptRegistry<MapleStorySocketIPv4TCP, MongoModelStorage>()
