//// Sources/App/configure.swift
//import Vapor
//import Fluent
//import FluentMySQLDriver
//import JWT
//
//public func configure(_ app: Application) async throws {
//    // Database configuration
//    var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
//    // This is the key line: it tells the client to not verify the server's certificate.
//    tlsConfiguration.certificateVerification = .none
//    
//    app.databases.use(.mysql(
//        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
//        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 3306,
//        username: Environment.get("DATABASE_USERNAME") ?? "root",
//        password: Environment.get("DATABASE_PASSWORD") ?? "",
//        database: Environment.get("DATABASE_NAME") ?? "headless_cms",
//        tlsConfiguration: tlsConfiguration // <-- Add this parameter
//    ), as: .mysql)
//    
//    // JWT configuration
//    // Correctly initialize HMACKey from the string secret
//    await app.jwt.keys.add(hmac: HMACKey(stringLiteral: Environment.get("JWT_SECRET") ?? "secret-key"), digestAlgorithm: .sha256)
//    
//    // Migrations
//    app.migrations.add(CreateUser())
//    app.migrations.add(CreateArticle())
//    
//    try await app.autoMigrate()
//    
//    // Routes
//    try routes(app)
//}

// Sources/App/configure.swift
import Vapor
import Fluent
import FluentMySQLDriver
import JWT

public func configure(_ app: Application) async throws {
    // Database configuration
    app.databases.use(.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "127.0.0.1",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 3306,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "zupp_cms",
        tlsConfiguration: .forClient(certificateVerification: .none) // 👈 disable SSL verification
    ), as: .mysql)

    
    // JWT configuration
    await app.jwt.keys.add(hmac: HMACKey(stringLiteral: Environment.get("JWT_SECRET") ?? "secret-key"), digestAlgorithm: .sha256)
        
    // Migrations
    // app.migrations.add(CreateUser())
    // app.migrations.add(CreateArticle())
    
    // Comment this out if tables already exist
    // try await app.autoMigrate()
    
    // Routes
    try routes(app)
}
