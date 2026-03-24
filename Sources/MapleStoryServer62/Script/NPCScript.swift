//
//  NPCScript.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// An NPC script is an async function that receives a context and drives
/// the conversation by calling the context's `send*` methods.
public typealias NPCScript = @Sendable (NPCScriptContext) async throws -> Void

/// Registry that maps NPC template IDs to their scripts.
///
/// Register scripts at startup (e.g. in `ChannelServerCommand.run()`):
/// ```swift
/// NPCScriptRegistry.shared.register(npc: 1012100) { ctx in
///     try await ctx.sendOk("Hello, traveller!")
/// }
/// ```
public final class NPCScriptRegistry: @unchecked Sendable {

    public static let shared = NPCScriptRegistry()

    private var scripts = [UInt32: NPCScript]()

    private let lock = NSLock()

    private init() { }

    public func register(npc id: UInt32, _ script: @escaping NPCScript) {
        lock.withLock { scripts[id] = script }
    }

    public func script(for npcID: UInt32) -> NPCScript? {
        lock.withLock { scripts[npcID] }
    }
}
