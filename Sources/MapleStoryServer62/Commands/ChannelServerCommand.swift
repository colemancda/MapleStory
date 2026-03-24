//
//  ChannelServer.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import ArgumentParser
import NIO
import Socket
import CoreModel
import MongoDBModel
import MapleStory62
import MapleStoryServer

struct ChannelServerCommand: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "channel",
        abstract: "Run the channel server."
    )

    @Option(help: "World Index")
    var world: Int = 1

    @Option(help: "Channel Index")
    var channel: Int = 1

    @Option(help: "Address to bind server.")
    var address: String?

    @Option(help: "Port to bind server.")
    var port: UInt16 = 7575

    @Option(help: "Server backlog.")
    var backlog: Int = 1000

    @Option(help: "Database URL.")
    var databaseURL: String = "mongodb://localhost:27017"

    @Option(help: "Database username.")
    var databaseUsername: String?

    @Option(help: "Database password.")
    var databasePassword: String?

    @Option(help: "Database name.")
    var databaseName: String = "maplestory"

    @Option(help: "Path to extracted Mob.wz directory (optional, enables server-side mob validation).")
    var mobWzPath: String?

    func validate() throws {
        if let address {
            guard let _ = MapleStoryAddress(address: address, port: port) else {
                throw MapleStoryError.invalidAddress(address)
            }
        }
        guard world > 0 else {
            throw MapleStoryError.invalidWorld
        }
        guard channel > 0 else {
            throw MapleStoryError.invalidChannel
        }
    }

    func run() async throws {
        
        defer { cleanupMongoSwift() }
        
        // start server
        let ipAddress = self.address ?? IPv4Address.any.rawValue
        guard let address = MapleStoryAddress(address: ipAddress, port: port) else {
            throw MapleStoryError.invalidAddress(ipAddress)
        }
        
        let configuration = ServerConfiguration(
            address: address,
            backlog: backlog,
            version: .v62
        )
        
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        
        defer {
            try? elg.syncShutdownGracefully()
        }
        
        let mongoClient = try MongoClient(
            databaseURL,
            using: elg,
            options: MongoClientOptions(
                credential: MongoCredential(
                    username: databaseUsername,
                    password: databasePassword
                )
            )
        )
        
        defer {
            try? mongoClient.syncClose()
        }
        
        let store = MongoModelStorage(
            database: mongoClient.db(databaseName),
            model: .mapleStory
        )
        
        try await store.initializeMapleStory(
            version: configuration.version,
            region: configuration.region
        )
        
        let server = try await MapleStoryServer<MapleStorySocketIPv4TCP, MongoModelStorage, ClientOpcode, ServerOpcode>(
            configuration: configuration,
            database: store,
            socket: MapleStorySocketIPv4TCP.self
        )

        guard let world = try await World.fetch(
            index: World.Index(self.world - 1),
            version: configuration.version,
            region: configuration.region,
            in: store
        ) else {
            throw MapleStoryError.invalidWorld
        }

        guard let channelObj = try await MapleStory.Channel.fetch(
            MapleStory.Channel.Index(self.channel - 1),
            world: world.id,
            in: store
        ) else {
            throw MapleStoryError.invalidChannel
        }

        if let mobWzPath {
            await MobDataCache.shared.load(from: URL(fileURLWithPath: mobWzPath))
        }
        NPCScriptRegistry.shared.registerAll()
        await server.registerChannelServer(channel: channelObj.id)

        try await Task.sleep(for: .seconds(Date.distantFuture.timeIntervalSinceNow))

        // retain
        let _ = server
    }
}

public extension MapleStoryServer where ClientOpcode == MapleStory62.ClientOpcode, ServerOpcode == MapleStory62.ServerOpcode {

    func registerChannelServer(channel: MapleStory.Channel.ID) async {
        await register(HandshakeHandler(channel: channel))
        await register(PingHandler())
        await register(PlayerLoginRequestHandler(channel: channel))
        await register(MovePlayerHandler())
        await register(PlayerUpdateHandler())
        await register(HealOverTimeHandler())
        await register(GeneralChatHandler())
        await register(NPCTalkHandler())
        await register(NPCActionHandler())
        await register(ChangeMapSpecialHandler())
        await register(ChangeMapHandler())
        await register(ChangeChannelHandler())
        await register(FaceExpressionHandler())
        await register(DistributeAPHandler())
        await register(DistributeSPHandler())
        await register(SpecialMoveHandler())
        await register(CancelBuffHandler())
        await register(ItemMoveHandler())
        await register(MesoDropHandler())
        await register(QuestActionHandler())
        await register(CharInfoRequestHandler())
        await register(GiveFameHandler())
        await register(UseItemHandler())
        await register(ItemPickupHandler())
        await register(MoveLifeHandler())
        // Combat
        await register(CloseRangeAttackHandler())
        await register(RangedAttackHandler())
        await register(MagicAttackHandler())
        await register(TakeDamageHandler())
        await register(SkillEffectHandler())
        await register(AutoAggroHandler())
        await register(MonsterBombHandler())
        await register(DamageReactorHandler())
        await register(MoveSummonHandler())
        await register(SummonAttackHandler())
        await register(DamageSummonHandler())
        // Items
        await register(CancelItemEffectHandler())
        await register(CancelDebuffHandler())
        await register(UseUpgradeScrollHandler())
        await register(UseSkillBookHandler())
        await register(UseReturnScrollHandler())
        await register(ItemSortHandler())
        await register(UseInnerPortalHandler())
        await register(TrockAddMapHandler())
        await register(UseDoorHandler())
        await register(UseSummonBagHandler())
        await register(UseMountFoodHandler())
        await register(UseCashItemHandler())
        await register(UseCatchItemHandler())
        await register(UseChairHandler())
        await register(CancelChairHandler())
        // NPC / Shop
        await register(NPCTalkMoreHandler())
        await register(NPCShopHandler())
        await register(StorageHandler())
        await register(DueyActionHandler())
        // Social
        await register(PartyChatHandler())
        await register(WhisperHandler())
        await register(SpouseChatHandler())
        await register(MessengerHandler())
        await register(PartyOperationHandler())
        await register(DenyPartyRequestHandler())
        await register(GuildOperationHandler())
        await register(DenyGuildRequestHandler())
        await register(BuddyListModifyHandler())
        await register(NoteActionHandler())
        await register(RingActionHandler())
        await register(PlayerShopHandler())
        // UI / Other
        await register(CloseChalkboardHandler())
        await register(SkillMacroHandler())
        await register(ReportHandler())
        await register(ChangeKeymapHandler())
        await register(EnterCashShopHandler())
        await register(TouchingCSHandler())
        await register(BuyCSItemHandler())
        await register(CouponCodeHandler())
        await register(EnterMTSHandler())
        await register(MapleTVHandler())
        await register(MTSOperationHandler())
        await register(MonsterCarnivalHandler())
        await register(PartySearchRegisterHandler())
        await register(PartySearchStartHandler())
        // Pets
        await register(SpawnPetHandler())
        await register(MovePetHandler())
        await register(PetTalkHandler())
        await register(PetChatHandler())
        await register(PetCommandHandler())
        await register(PetFoodHandler())
        await register(PetLootHandler())
        await register(PetAutoPotHandler())
    }
}
