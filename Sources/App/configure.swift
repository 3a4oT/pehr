import FluentSQLite
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    // try SQLiteDatabase(storage: .memory)
    let sqlite = try SQLiteDatabase(storage: .file(path: "EnvHealthBot.sqlite"))

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    var migrationsConfig = MigrationConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    migrationsConfig.add(model: BotRegistration.self, database: .sqlite)
    migrationsConfig.add(model: EnvStatus.self, database: .sqlite)
    
    services.register(migrationsConfig)
    services.register(DatabaseConnectionPoolConfig(maxConnections: 8))
    
    //////////////////////////////////
    /////// Custom APIKeyService
    /////////////////////////////////
    services.register { container -> APIKeyStorage in
        return APIKeyStorage(clientId: Environment.slackClientID,
                             clientSecret: Environment.slackClientSecret)
    }
    services.register { (container) -> EnvHealthConfig in
        
        let url: URL? = URL(string: Environment.envURL)
        guard let baseURL = url?.appendingPathComponent(Environment.envPath) else {
            throw Abort.init(HTTPResponseStatus.internalServerError)
        }
        return EnvHealthConfig(url: baseURL)
    }
    
    //////////////////////////////////
    /////// LEAF
    /////////////////////////////////
    services.register { container -> LeafRenderer in
        let directoryConfig = try container.make(DirectoryConfig.self)
        let viewsDirectory = directoryConfig.workDir + "Resources/Views"
        let config = LeafConfig(tags: LeafTagConfig.default(), viewsDir: viewsDirectory, shouldCache: true)
        return LeafRenderer(config: config, using: container)
    }
    
    //////////////////////////////////
    /////// EnvHealthBot
    //////////////////////////////////
    services.register(EnvHealthBot.self)
}
