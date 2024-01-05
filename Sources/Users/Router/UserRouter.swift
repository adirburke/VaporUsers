//  Created by Adir Burke on 5/1/2024.
//

import Vapor
import FluentPostgresDriver

struct UserRouter: RouteCollection {
     func boot(routes: RoutesBuilder) throws {
         
         let tokenProtected = routes.grouped(HeaderCodeAuth())
         
         tokenProtected.post("users") { req -> EventLoopFuture<User> in
            try User.Create.validate(content: req)
            let create = try req.content.decode(User.Create.self)
            let user = User(email: create.email, password: try Bcrypt.hash(create.password))
            return user.save(on: req.db)
                .map { user }
        }
         
         let allProtected = routes
             .grouped(User.authenticator(database: .psql))
             .grouped(UserToken.authenticator(database: .psql))
             .grouped(User.guardMiddleware())
        
        allProtected.get("login") { req -> EventLoopFuture<UserToken.ReturnToken> in
            let user = try req.auth.require(User.self)
            let token = try user.generateToken()
            return token.save(on: req.db)
                .map { UserToken.ReturnToken(value: token.value) }
        }
    }
    
    init() {}
    
    
}
