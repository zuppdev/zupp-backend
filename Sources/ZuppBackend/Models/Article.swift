
// Sources/App/Models/Article.swift
import Vapor
import Fluent

final class Article: Model, Content, @unchecked Sendable {
    static let schema = "articles"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "slug")
    var slug: String
    
    @Field(key: "content")
    var content: String
    
    @Field(key: "excerpt")
    var excerpt: String?
    
    @Field(key: "published")
    var published: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, title: String, slug: String, content: String, excerpt: String? = nil, published: Bool = false) {
        self.id = id
        self.title = title
        self.slug = slug
        self.content = content
        self.excerpt = excerpt
        self.published = published
    }
}
