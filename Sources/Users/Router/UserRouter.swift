//  Created by Adir Burke on 5/1/2024.
//

import Vapor
import FluentPostgresDriver

public struct UserRouter: RouteCollection {
    let headerAuth : HeaderCodeAuth
    
    public func boot(routes: RoutesBuilder) throws {
         
         let tokenProtected = routes.grouped(headerAuth)
         
         tokenProtected.post("users") { req -> EventLoopFuture<User> in
            try User.Create.validate(content: req)
            let create = try req.content.decode(User.Create.self)
            let user = User(email: create.email, password: try Bcrypt.hash(create.password))
            return user.save(on: req.db)
                .map { user }
        }
        
        routes
            .grouped(User.authenticator(database: .psql))
            .grouped(UserToken.authenticator(database: .psql))
            .grouped(User.guardMiddleware())
            .get("login") { req -> EventLoopFuture<UserToken.ReturnToken> in
            let user = try req.auth.require(User.self)
            let token = try user.generateToken()
            return token.save(on: req.db)
                .flatMapThrowing { try UserToken.ReturnToken(value: token.value, userId: user.requireID()) }
        }
        
        routes
            .grouped(UserToken.authenticator(database: .psql))
            .grouped(User.guardMiddleware())
            .get("logout") { req async throws -> HTTPStatus in
            guard let token = req.headers.bearerAuthorization?.token else { throw Abort(.badRequest) }
            try await UserToken.query(on: req.db).filter(\UserToken.$value == token).delete()
            return .ok
        }
    }
    
    public init(authCode: String) {
        self.headerAuth = HeaderCodeAuth(authCode)
    }
    
    
}
