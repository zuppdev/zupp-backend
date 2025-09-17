// Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        return ["message": "Headless CMS API"]
    }
    
    try app.register(collection: AuthController())
    try app.register(collection: ArticleController())
}
