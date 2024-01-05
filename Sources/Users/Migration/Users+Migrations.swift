//  Created by Adir Burke on 22/7/21.
//

import Fluent

public struct CreateUser : Migration {
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Schema.schema).delete()
    }
    
    typealias Schema = User
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Schema.schema)
            .id()
            .field(FieldKey.User.email, .string, .required)
            .field(FieldKey.User.active, .bool, .required)
            .field(FieldKey.User.passwordHash, .string, .required)
            .unique(on: FieldKey.User.email)
            .create()
    }
}

public extension UserToken {
    struct Migration: Fluent.Migration {
        typealias Schema = UserToken
        public var name: String { "CreateUserToken" }

        public func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Schema.schema)
                .id()
                .field(FieldKey.UserToken.value, .string, .required)
                .field(.userId, .uuid, .required, .references(User.schema, "id"))
                .unique(on: FieldKey.UserToken.value)
                .create()
        }

        public func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Schema.schema).delete()
        }
    }
}
