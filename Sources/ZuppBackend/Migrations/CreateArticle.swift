//
//  CreateArticle.swift
//  ZuppBackend
//
//  Created by Zap on 14/09/25.
//


// Sources/App/Migrations/CreateArticle.swift
import Fluent

struct CreateArticle: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("articles")
            .id()
            .field("title", .string, .required)
            .field("slug", .string, .required)
            .field("content", .custom("LONGTEXT"), .required)
            .field("excerpt", .string)
            .field("published", .bool, .required, .custom("DEFAULT FALSE"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "slug")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("articles").delete()
    }
}
