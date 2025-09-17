// Sources/App/Models/User.swift
import Vapor
import Fluent
import JWTKit
final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "is_admin")
    var isAdmin: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, email: String, passwordHash: String, isAdmin: Bool = false) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.isAdmin = isAdmin
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey: KeyPath<User, Field<String>> { \User.$email }
    static var passwordHashKey: KeyPath<User, Field<String>> { \User.$passwordHash }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

struct UserToken: Content, Authenticatable, JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case isAdmin = "admin"
    }
    
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var isAdmin: Bool
    
    func verify(using key: some JWTAlgorithm) throws {
        try self.expiration.verifyNotExpired()
    }
}
