
// Sources/App/Controllers/ArticleController.swift
import Vapor
import Fluent

struct ArticleController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let articles = routes.grouped("articles")
        
        // Public routes
        articles.get(use: index)
        articles.get(":slug", use: show)
        
        // Admin routes
        let protected = articles.grouped(UserToken.authenticator(), UserToken.guardMiddleware())
        protected.post(use: create)
        protected.put(":id", use: update)
        protected.delete(":id", use: delete)
    }
    
    func index(req: Request) async throws -> [Article] {
        return try await Article.query(on: req.db)
            .filter(\.$published == true)
            .sort(\.$createdAt, .descending)
            .all()
    }
    
    func show(req: Request) async throws -> Article {
        guard let article = try await Article.query(on: req.db)
            .filter(\.$slug == req.parameters.get("slug")!)
            .filter(\.$published == true)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        return article
    }
    
    func create(req: Request) async throws -> Article {
        let token = try req.auth.require(UserToken.self)
        guard token.isAdmin else { throw Abort(.forbidden) }
        
        let articleRequest = try req.content.decode(ArticleRequest.self)
        let article = Article(
            title: articleRequest.title,
            slug: articleRequest.slug,
            content: articleRequest.content,
            excerpt: articleRequest.excerpt,
            published: articleRequest.published
        )
        
        try await article.save(on: req.db)
        return article
    }
    
    func update(req: Request) async throws -> Article {
        let token = try req.auth.require(UserToken.self)
        guard token.isAdmin else { throw Abort(.forbidden) }
        
        guard let article = try await Article.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let articleRequest = try req.content.decode(ArticleRequest.self)
        article.title = articleRequest.title
        article.slug = articleRequest.slug
        article.content = articleRequest.content
        article.excerpt = articleRequest.excerpt
        article.published = articleRequest.published
        
        try await article.save(on: req.db)
        return article
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let token = try req.auth.require(UserToken.self)
        guard token.isAdmin else { throw Abort(.forbidden) }
        
        guard let article = try await Article.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await article.delete(on: req.db)
        return .noContent
    }
}

struct ArticleRequest: Content {
    let title: String
    let slug: String
    let content: String
    let excerpt: String?
    let published: Bool
}
