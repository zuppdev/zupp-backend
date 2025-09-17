

// Sources/App/Controllers/AuthController.swift
import Vapor
import Fluent
import JWT

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("login", use: login)
        auth.post("register", use: register)
    }
    
    func login(req: Request) async throws -> AuthResponse {
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first()
        else {
            throw Abort(.unauthorized)
        }
        
        guard try user.verify(password: loginRequest.password) else {
            throw Abort(.unauthorized)
        }
        
        let payload = UserToken(
            subject: SubjectClaim(value: user.id!.uuidString),
            expiration: ExpirationClaim(value: Date().addingTimeInterval(86400 * 7)),
            isAdmin: user.isAdmin
        )
        
        let token = try await req.jwt.sign(payload)
        
        return AuthResponse(
            user: UserResponse(
                id: user.id!,
                email: user.email,
                isAdmin: user.isAdmin
            ),
            token: token
        )
    }
    
    func register(req: Request) async throws -> AuthResponse {
        let registerRequest = try req.content.decode(RegisterRequest.self)
        
        let existingUser = try await User.query(on: req.db)
            .filter(\.$email == registerRequest.email)
            .first()
        
        if existingUser != nil {
            throw Abort(.badRequest, reason: "Email already exists")
        }
        
        let passwordHash = try Bcrypt.hash(registerRequest.password)
        let user = User(email: registerRequest.email, passwordHash: passwordHash)
        
        try await user.save(on: req.db)
        
        let payload = UserToken(
            subject: SubjectClaim(value: user.id!.uuidString),
            expiration: ExpirationClaim(value: Date().addingTimeInterval(86400 * 7)),
            isAdmin: user.isAdmin
        )
        
        let token = try await req.jwt.sign(payload)
        
        return AuthResponse(
            user: UserResponse(
                id: user.id!,
                email: user.email,
                isAdmin: user.isAdmin
            ),
            token: token
        )
    }
}

struct LoginRequest: Content {
    let email: String
    let password: String
}

struct RegisterRequest: Content {
    let email: String
    let password: String
}

struct UserResponse: Content {
    let id: UUID
    let email: String
    let isAdmin: Bool
}

struct AuthResponse: Content {
    let user: UserResponse
    let token: String
}
