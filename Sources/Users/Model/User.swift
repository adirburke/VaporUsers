//  Created by Adir Burke on 13/6/21.
//

import Foundation
import Fluent
import Vapor

extension FieldKey {
    struct User {
        static var email : FieldKey { "email" }
        static var passwordHash : FieldKey { "hash" }
        static var active : FieldKey { "active" }
    }
}

public final class User : Content, Model {
    public static var schema: String = "user"
    
    @ID(key: .id) public var id : UUID?
    
    @Field(key: FieldKey.User.email) public var email : String
    @Field(key: FieldKey.User.passwordHash) public var passwordHash: String
    @Field(key: FieldKey.User.active) public var isActive : Bool
    
    
    public init() {}
    public init(email : String, password : String) {
        self.email = email
        self.passwordHash = password
        self.isActive = true
    }
}

public extension User {
    struct Create: Content {
        public var email: String
        public var password: String
    }
}

extension User.Create: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}


extension User: ModelAuthenticatable {
    public static let usernameKey = \User.$email
    public static let passwordHashKey = \User.$passwordHash

    public func verify(password: String) throws -> Bool {
        if self.isActive {
            return try Bcrypt.verify(password, created: self.passwordHash)
        }
        return false
    }
}

public extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}
