//  Created by Adir Burke on 13/6/21.
//

import Fluent
import Vapor

extension FieldKey {
    static var userId : FieldKey { "userid" }
    struct UserToken {
        static var value : FieldKey { "value" }
       
    }
}

public final class UserToken: Model, Content {
    
    struct ReturnToken : Content {
        var value: String
        var userId : UUID
    }
    public static let schema = "user_tokens"

    @ID(key: .id) public var id: UUID?

    @Field(key: FieldKey.UserToken.value) public var value: String

    @Parent(key: .userId) public var user: User

    public init() { }

    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension UserToken: ModelTokenAuthenticatable {
    public static let valueKey = \UserToken.$value
    public static let userKey = \UserToken.$user

    
    var __$value: Field<String> {
        self[keyPath: Self.valueKey]
    }
    var _$user: Parent<User> {
        self[keyPath: Self.userKey]
    }
    
    public static func authenticator(database: DatabaseID? = nil) -> Authenticator {
        ModelTokenAuthenticatorEager(database: database)
    }
    
    public var isValid: Bool {
        return self.user.isActive
    }
}

private struct ModelTokenAuthenticatorEager: BearerAuthenticator
{
    public typealias Token = UserToken
    public typealias User = Token.User
    public let database: DatabaseID?

    public func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {
        let db = request.db(self.database)
        return Token.query(on: db).with(\.$user)
            .filter(\.__$value == bearer.token)
            .first()
            .flatMap
        { token -> EventLoopFuture<Void> in
            guard let token = token else {
                return request.eventLoop.makeSucceededFuture(())
            }
                guard token.isValid else {
                    return token.delete(on: db)
                }
                request.auth.login(token)
                request.auth.login(token.user)
                return request.eventLoop.makeSucceededFuture(())
        }
    }
}
